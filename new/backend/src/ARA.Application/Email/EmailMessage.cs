namespace ARA.Application.Email;

/// <summary>
/// Represents an email notification triggered by an ARA workflow event.
/// </summary>
public sealed class EmailMessage
{
    /// <summary>Gets the ARA ID this email relates to.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the workflow event that triggered this email.</summary>
    public EmailEventType EventType { get; init; }

    /// <summary>Gets the semicolon-delimited list of recipient email addresses.</summary>
    public string Recipients { get; init; } = string.Empty;

    /// <summary>Gets the optional semicolon-delimited CC recipients.</summary>
    public string? CcRecipients { get; init; }

    /// <summary>Gets the email subject line.</summary>
    public string Subject { get; init; } = string.Empty;

    /// <summary>Gets the HTML body content.</summary>
    public string HtmlBody { get; init; } = string.Empty;

    /// <summary>Gets the plain-text body content (fallback for non-HTML clients).</summary>
    public string TextBody { get; init; } = string.Empty;

    /// <summary>Gets the user ID of the person whose action triggered this email.</summary>
    public int? TriggeredByUserId { get; init; }
}
