namespace ARA.Infrastructure.Email;

/// <summary>
/// Bound to the <c>Email</c> configuration section. Drives DI selection between
/// <see cref="LoggingEmailService"/> (when <see cref="SmtpOptions.Host"/> is empty) and
/// <see cref="M365SmtpEmailService"/> (when host is set).
/// </summary>
public sealed class EmailOptions
{
    /// <summary>SMTP relay configuration. Empty <see cref="SmtpOptions.Host"/> means "no SMTP — fall back to logging."</summary>
    public SmtpOptions Smtp { get; set; } = new();

    /// <summary>From-address used on the envelope when <see cref="M365SmtpEmailService"/> sends.</summary>
    public string FromAddress { get; set; } = string.Empty;
}

/// <summary>
/// SMTP relay settings. The on-prem M365 / Exchange relay does not require authentication —
/// mail flow works because the server's IP is on the relay's allowlist (D6 of the on-prem
/// pivot). Username and password fields are intentionally absent.
/// </summary>
public sealed class SmtpOptions
{
    /// <summary>SMTP server hostname. Empty / null / whitespace means "no SMTP" and the DI fallback selects <see cref="LoggingEmailService"/>.</summary>
    public string Host { get; set; } = string.Empty;

    /// <summary>SMTP server port. No hard-coded default — operator sets per relay (commonly 25 or 587).</summary>
    public int Port { get; set; }

    /// <summary>
    /// MailKit <c>SecureSocketOptions</c> as a string. Valid values:
    /// <c>None</c>, <c>Auto</c>, <c>SslOnConnect</c>, <c>StartTls</c>, <c>StartTlsWhenAvailable</c>.
    /// Default <c>Auto</c> lets MailKit negotiate based on the port. Validated at startup.
    /// </summary>
    public string SecureSocketOptions { get; set; } = "Auto";
}
