using System.Data;
using ARA.Application.Email;
using ARA.Infrastructure.Database;
using Dapper;
using MailKit.Security;
using Microsoft.Extensions.Logging;
using MimeKit;

namespace ARA.Infrastructure.Email;

/// <summary>
/// SMTP-relay email service for the on-prem M365 / Exchange path (D6 of the on-prem pivot).
/// Selected by DI when <c>Email:Smtp:Host</c> is configured; otherwise the DI fallback picks
/// <see cref="LoggingEmailService"/>. Authentication is intentionally skipped — the on-prem
/// relay allowlists this server's IP. Every send is mirrored to the <c>EmailLog</c> table
/// (via the existing <c>usp_EmailLogCreate</c>) so the audit trail is preserved regardless
/// of provider, and every send (success and failure) is logged with structured fields.
/// </summary>
public sealed class M365SmtpEmailService : IEmailService
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly Func<IMailKitSmtpClient> _smtpClientFactory;
    private readonly ILogger<M365SmtpEmailService> _logger;
    private readonly string _host;
    private readonly int _port;
    private readonly SecureSocketOptions _secureSocketOptions;
    private readonly string _fromAddress;

    /// <summary>
    /// Initializes a new instance of <see cref="M365SmtpEmailService"/>.
    /// Registration code (<see cref="InfrastructureServiceExtensions"/>) validates the
    /// <see cref="EmailOptions"/> shape before this constructor is reached.
    /// </summary>
    public M365SmtpEmailService(
        IDbConnectionFactory connectionFactory,
        Func<IMailKitSmtpClient> smtpClientFactory,
        ILogger<M365SmtpEmailService> logger,
        string host,
        int port,
        SecureSocketOptions secureSocketOptions,
        string fromAddress)
    {
        _connectionFactory = connectionFactory;
        _smtpClientFactory = smtpClientFactory;
        _logger = logger;
        _host = host;
        _port = port;
        _secureSocketOptions = secureSocketOptions;
        _fromAddress = fromAddress;
    }

    /// <inheritdoc/>
    public async Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        await WriteEmailLogAsync(message, cancellationToken);

        _logger.LogInformation(
            "[SMTP SEND START] Event={EventType} ARA={AraId} To={Recipients} CC={Cc} Subject={Subject} Host={Host} Port={Port} SecureSocketOptions={Sso}",
            message.EventType,
            message.AraId,
            message.Recipients,
            message.CcRecipients,
            message.Subject,
            _host,
            _port,
            _secureSocketOptions);

        DateTimeOffset start = DateTimeOffset.UtcNow;
        using IMailKitSmtpClient client = _smtpClientFactory();
        try
        {
            MimeMessage mime = BuildMimeMessage(message);

            await client.ConnectAsync(_host, _port, _secureSocketOptions, cancellationToken);
            await client.SendAsync(mime, cancellationToken);
            await client.DisconnectAsync(quit: true, cancellationToken);

            _logger.LogInformation(
                "[SMTP SEND OK] Event={EventType} ARA={AraId} To={Recipients} Subject={Subject} ElapsedMs={ElapsedMs}",
                message.EventType,
                message.AraId,
                message.Recipients,
                message.Subject,
                (DateTimeOffset.UtcNow - start).TotalMilliseconds);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "[SMTP SEND FAIL] Event={EventType} ARA={AraId} To={Recipients} Subject={Subject} Host={Host} Port={Port} ElapsedMs={ElapsedMs}",
                message.EventType,
                message.AraId,
                message.Recipients,
                message.Subject,
                _host,
                _port,
                (DateTimeOffset.UtcNow - start).TotalMilliseconds);
            throw;
        }
    }

    private MimeMessage BuildMimeMessage(EmailMessage message)
    {
        MimeMessage mime = new();
        mime.From.Add(MailboxAddress.Parse(_fromAddress));

        foreach (string addr in SplitAddresses(message.Recipients))
        {
            mime.To.Add(MailboxAddress.Parse(addr));
        }

        if (!string.IsNullOrWhiteSpace(message.CcRecipients))
        {
            foreach (string addr in SplitAddresses(message.CcRecipients))
            {
                mime.Cc.Add(MailboxAddress.Parse(addr));
            }
        }

        mime.Subject = message.Subject;

        BodyBuilder body = new()
        {
            HtmlBody = message.HtmlBody,
            TextBody = message.TextBody,
        };
        mime.Body = body.ToMessageBody();

        return mime;
    }

    private static IEnumerable<string> SplitAddresses(string semicolonDelimited) =>
        semicolonDelimited
            .Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    private async Task WriteEmailLogAsync(EmailMessage message, CancellationToken cancellationToken)
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
    }
}
