using System.Data;
using ARA.Application.Email;
using ARA.Infrastructure.Database;
using Dapper;
using Microsoft.Extensions.Logging;

namespace ARA.Infrastructure.Email;

/// <summary>
/// Email service implementation that logs all emails to the database <c>EmailLog</c> table
/// instead of sending them. This allows the full workflow to function in development and
/// testing without requiring an email provider. Swap this implementation for a real email
/// service (Azure Communication Services, SendGrid, SMTP) when credentials are available.
/// </summary>
public sealed class LoggingEmailService : IEmailService
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly ILogger<LoggingEmailService> _logger;

    /// <summary>Initializes a new instance of <see cref="LoggingEmailService"/>.</summary>
    public LoggingEmailService(
        IDbConnectionFactory connectionFactory,
        ILogger<LoggingEmailService> logger)
    {
        _connectionFactory = connectionFactory;
        _logger            = logger;
    }

    /// <inheritdoc/>
    public async Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        using IDbConnection connection = await _connectionFactory.CreateAsync(cancellationToken);

        await connection.ExecuteAsync(
            "usp_EmailLogCreate",
            new
            {
                AraId = message.AraId,
                EmailTypeId = (int)message.EventType,
                Recipients = message.Recipients,
                CcRecipients = message.CcRecipients,
                Subject = message.Subject,
                Body = message.HtmlBody,
                SentByUserId = message.TriggeredByUserId,
            },
            commandType: CommandType.StoredProcedure);

        _logger.LogInformation(
            "[EMAIL LOGGED] Event={EventType} ARA={AraId} To={Recipients} Subject={Subject}",
            message.EventType,
            message.AraId,
            message.Recipients,
            message.Subject);
    }
}
