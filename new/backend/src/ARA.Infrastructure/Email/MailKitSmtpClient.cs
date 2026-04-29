using MailKit.Security;
using MimeKit;

namespace ARA.Infrastructure.Email;

/// <summary>
/// Default <see cref="IMailKitSmtpClient"/> wrapper around <see cref="MailKit.Net.Smtp.SmtpClient"/>.
/// One instance per send (registered transient by DI). No authentication is performed —
/// the on-prem M365 / Exchange relay accepts mail based on source-IP allowlist (D6).
/// </summary>
public sealed class MailKitSmtpClient : IMailKitSmtpClient
{
    private readonly MailKit.Net.Smtp.SmtpClient _client = new();

    /// <inheritdoc/>
    public Task ConnectAsync(string host, int port, SecureSocketOptions secureSocketOptions, CancellationToken cancellationToken) =>
        _client.ConnectAsync(host, port, secureSocketOptions, cancellationToken);

    /// <inheritdoc/>
    public async Task SendAsync(MimeMessage message, CancellationToken cancellationToken) =>
        await _client.SendAsync(message, cancellationToken);

    /// <inheritdoc/>
    public Task DisconnectAsync(bool quit, CancellationToken cancellationToken) =>
        _client.DisconnectAsync(quit, cancellationToken);

    /// <inheritdoc/>
    public void Dispose() => _client.Dispose();
}
