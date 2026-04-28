namespace ARA.Application.Email;

/// <summary>
/// Builds <see cref="EmailMessage"/> instances for ARA workflow events.
/// Centralizes email content construction so callers only need to specify
/// the event type and the relevant ARA + user data.
/// </summary>
public static class AraEmailBuilder
{
    private const string SenderName = "ARA System";
    private const string AraBaseUrl = "/aras/";

    /// <summary>Builds an email for when the PM submits an ARA to the CA.</summary>
    public static EmailMessage PmSubmitted(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User pm, ARA.Domain.Entities.User ca)
    {
        string subject = $"ARA {ara.AraId} submitted by {pm.DisplayName} — awaiting your review";
        string body = BuildBody(ara, $"{pm.DisplayName} has signed and submitted ARA {ara.AraId}. It is now awaiting your review as Contract Administrator.");
        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.PmSubmitted,
            Recipients = ca.Email,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = pm.UserId,
        };
    }

    /// <summary>Builds an email for when the CA submits an ARA to the Controller.</summary>
    public static EmailMessage CaSubmitted(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User ca, ARA.Domain.Entities.User controller)
    {
        string subject = $"ARA {ara.AraId} submitted by CA — awaiting Controller review";
        string body = BuildBody(ara, $"{ca.DisplayName} has submitted ARA {ara.AraId} for Controller review.");
        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.CaSubmitted,
            Recipients = controller.Email,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = ca.UserId,
        };
    }

    /// <summary>Builds an email for when the Controller submits an ARA for approval.</summary>
    public static EmailMessage ControllerSubmitted(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User controller, string approverEmail)
    {
        string subject = $"ARA {ara.AraId} submitted for approval — awaiting your action";
        string body = BuildBody(ara, $"{controller.DisplayName} has submitted ARA {ara.AraId} for approval.");
        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.ControllerSubmitted,
            Recipients = approverEmail,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = controller.UserId,
        };
    }

    /// <summary>Builds notification emails when an approver approves.</summary>
    public static EmailMessage ApproverApproved(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User approver, string priorActorEmails, string? nextApproverEmail)
    {
        string subject = $"ARA {ara.AraId} approved by {approver.DisplayName}";
        string body = BuildBody(ara, $"{approver.DisplayName} has approved ARA {ara.AraId}.");

        string allRecipients = string.IsNullOrWhiteSpace(nextApproverEmail)
            ? priorActorEmails
            : $"{priorActorEmails};{nextApproverEmail}";

        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.ApproverApproved,
            Recipients = allRecipients,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = approver.UserId,
        };
    }

    /// <summary>Builds notification emails when an ARA is rejected.</summary>
    public static EmailMessage Rejected(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User rejector, string allPriorActorEmails, string? reason)
    {
        string reasonText = string.IsNullOrWhiteSpace(reason) ? "" : $" Reason: {reason}";
        string subject = $"ARA {ara.AraId} rejected by {rejector.DisplayName}";
        string body = BuildBody(ara, $"{rejector.DisplayName} has rejected ARA {ara.AraId}.{reasonText} The ARA has been returned to the Program Manager for revision.");
        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.Rejected,
            Recipients = allPriorActorEmails,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = rejector.UserId,
        };
    }

    /// <summary>Builds notification emails when an ARA is negated.</summary>
    public static EmailMessage ARANegated(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User ca, string allPartyEmails)
    {
        string subject = $"ARA {ara.AraId} negated by {ca.DisplayName}";
        string body = BuildBody(ara, $"{ca.DisplayName} has negated ARA {ara.AraId}. A contract modification has been received.");
        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.Negated,
            Recipients = allPartyEmails,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = ca.UserId,
        };
    }

    /// <summary>Builds notification emails when an ARA is cancelled.</summary>
    public static EmailMessage ARACancelled(ARA.Domain.Entities.Ara ara, ARA.Domain.Entities.User pm, string recipientEmails)
    {
        string subject = $"ARA {ara.AraId} cancelled by {pm.DisplayName}";
        string body = BuildBody(ara, $"{pm.DisplayName} has cancelled ARA {ara.AraId}.");
        return new EmailMessage
        {
            AraId = ara.AraId,
            EventType = EmailEventType.Cancelled,
            Recipients = recipientEmails,
            Subject = subject,
            HtmlBody = WrapHtml(body, ara.AraId),
            TextBody = body,
            TriggeredByUserId = pm.UserId,
        };
    }

    private static string BuildBody(ARA.Domain.Entities.Ara ara, string actionDescription)
    {
        return $"""
            {actionDescription}

            ARA ID: {ara.AraId}
            Contract: {ara.ContractNumber ?? "N/A"}
            Amount: {ara.AmountTotal:C2}
            Division: {ara.Division ?? "N/A"}
            Revision: {ara.Revision}
            """;
    }

    private static string WrapHtml(string textBody, int araId)
    {
        string link = $"{AraBaseUrl}{araId}";
        string escaped = System.Net.WebUtility.HtmlEncode(textBody).Replace("\n", "<br/>");
        return $"""
            <html><body>
            <p>{escaped}</p>
            <p><a href="{link}">View ARA {araId}</a></p>
            <hr/>
            <p style="color: #888; font-size: 12px;">Sent from {SenderName} (ara@hii-tsd.com). Do not reply to this email.</p>
            </body></html>
            """;
    }
}
