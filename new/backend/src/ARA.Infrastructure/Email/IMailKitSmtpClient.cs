using MailKit.Security;
using MimeKit;

namespace ARA.Infrastructure.Email;

/// <summary>
/// Thin abstraction over <see cref="MailKit.Net.Smtp.SmtpClient"/>. Exists so the
/// <see cref="M365SmtpEmailService"/> send path can be unit-tested without a live SMTP server.
/// The default implementation (<see cref="MailKitSmtpClient"/>) wraps MailKit 1:1.
/// </summary>
public interface IMailKitSmtpClient : IDisposable
{
    /// <summary>Connect to the SMTP host using the resolved <see cref="SecureSocketOptions"/>.</summary>
    Task ConnectAsync(string host, int port, SecureSocketOptions secureSocketOptions, CancellationToken cancellationToken);

    /// <summary>Send a single message. The on-prem relay does not require authentication; this implementation never calls <c>AuthenticateAsync</c>.</summary>
    Task SendAsync(MimeMessage message, CancellationToken cancellationToken);

    /// <summary>Disconnect cleanly with the SMTP <c>QUIT</c> verb.</summary>
    Task DisconnectAsync(bool quit, CancellationToken cancellationToken);
}
