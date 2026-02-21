using ARA.Application.Approval;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="RejectRequest"/>.</summary>
public sealed class RejectRequestValidator : AbstractValidator<RejectRequest>
{
    /// <summary>Initializes a new instance of <see cref="RejectRequestValidator"/>.</summary>
    public RejectRequestValidator()
    {
        RuleFor(x => x.Comment)
            .NotEmpty().WithMessage("A rejection comment is required.")
            .MaximumLength(2000).WithMessage("Rejection comment must not exceed 2000 characters.");
    }
}
