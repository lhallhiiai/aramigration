using ARA.Application.Email;
using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using ARA.Infrastructure.Email;
using ARA.Infrastructure.Repositories;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace ARA.Infrastructure;

/// <summary>
/// Registers all Infrastructure layer services with the dependency injection container.
/// Call <see cref="AddInfrastructure"/> from <c>Program.cs</c>.
/// </summary>
public static class InfrastructureServiceExtensions
{
    /// <summary>
    /// Adds the database connection factory, all repository implementations, and the
    /// email service appropriate for the current configuration.
    /// </summary>
    /// <param name="services">The service collection to configure.</param>
    /// <param name="configuration">Application configuration. The <c>Email</c> section
    /// drives the email-service selection: when <c>Email:Smtp:Host</c> is empty / null /
    /// whitespace, <see cref="LoggingEmailService"/> is registered (laptop dev path);
    /// when set, <see cref="M365SmtpEmailService"/> is registered against MailKit and
    /// the <c>Email:Smtp:SecureSocketOptions</c> string is validated at startup.</param>
    /// <returns>The same <paramref name="services"/> for chaining.</returns>
    /// <exception cref="InvalidOperationException">Thrown when SMTP is selected but
    /// required <c>Email</c> values are missing or invalid.</exception>
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddSingleton<IDbConnectionFactory, SqlConnectionFactory>();

        services.AddScoped<IAraRepository, AraRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IApprovalRecordRepository, ApprovalRecordRepository>();
        services.AddScoped<IDocumentRepository, DocumentRepository>();
        services.AddScoped<IClinEntryRepository, ClinEntryRepository>();
        services.AddScoped<ICategoryRepository, CategoryRepository>();
        services.AddScoped<IJobTitleRepository, JobTitleRepository>();
        services.AddScoped<IAraPmSectionRepository, AraPmSectionRepository>();
        services.AddScoped<IAraControllerSectionRepository, AraControllerSectionRepository>();
        services.AddScoped<IApprovalMatrixRepository, ApprovalMatrixRepository>();
        services.AddScoped<IDelegationRepository, DelegationRepository>();
        services.AddScoped<IRejectionReasonRepository, RejectionReasonRepository>();

        AddEmailService(services, configuration);

        return services;
    }

    /// <summary>
    /// Selects the email service implementation at startup based on whether an SMTP host
    /// is configured. Decision is made once at registration time, not per request.
    /// </summary>
    private static void AddEmailService(IServiceCollection services, IConfiguration configuration)
    {
        EmailOptions options = new();
        configuration.GetSection("Email").Bind(options);

        if (string.IsNullOrWhiteSpace(options.Smtp.Host))
        {
            services.AddScoped<IEmailService, LoggingEmailService>();
            return;
        }

        if (options.Smtp.Port <= 0)
        {
            throw new InvalidOperationException(
                "Email:Smtp:Host is configured but Email:Smtp:Port is missing or non-positive. " +
                "Set Email:Smtp:Port (commonly 25 or 587) in appsettings.Production.json.");
        }

        if (string.IsNullOrWhiteSpace(options.FromAddress))
        {
            throw new InvalidOperationException(
                "Email:Smtp:Host is configured but Email:FromAddress is missing. " +
                "Set Email:FromAddress (e.g. \"ara@hii-tsd.com\") in appsettings.Production.json.");
        }

        SecureSocketOptions secureSocketOptions = ParseSecureSocketOptions(options.Smtp.SecureSocketOptions);

        services.AddTransient<IMailKitSmtpClient, MailKitSmtpClient>();
        services.AddScoped<IEmailService>(sp => new M365SmtpEmailService(
            sp.GetRequiredService<IDbConnectionFactory>(),
            sp.GetRequiredService<IMailKitSmtpClient>,
            sp.GetRequiredService<ILogger<M365SmtpEmailService>>(),
            options.Smtp.Host,
            options.Smtp.Port,
            secureSocketOptions,
            options.FromAddress));
    }

    /// <summary>
    /// Parses the configured <c>Email:Smtp:SecureSocketOptions</c> string against MailKit's
    /// <see cref="SecureSocketOptions"/> enum. Fails fast with a descriptive error so an
    /// operator typo in <c>appsettings.Production.json</c> blocks startup rather than
    /// silently degrading the relay.
    /// </summary>
    public static SecureSocketOptions ParseSecureSocketOptions(string value)
    {
        if (Enum.TryParse(value, ignoreCase: true, out SecureSocketOptions parsed)
            && Enum.IsDefined(parsed))
        {
            return parsed;
        }

        string allowed = string.Join(", ", Enum.GetNames<SecureSocketOptions>());
        throw new InvalidOperationException(
            $"Email:Smtp:SecureSocketOptions value '{value}' is not a valid MailKit SecureSocketOptions. " +
            $"Allowed values: {allowed}.");
    }
}
