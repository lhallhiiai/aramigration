namespace ARA.Application.Email;

/// <summary>
/// Sends email notifications for ARA workflow events.
/// Implementations may send real email or log to the database for later dispatch.
/// </summary>
public interface IEmailService
{
    /// <summary>Sends an email notification asynchronously.</summary>
    /// <param name="message">The email message to send.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default);
}
