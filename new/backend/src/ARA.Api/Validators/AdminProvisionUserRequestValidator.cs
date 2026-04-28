using ARA.Application.Users;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="AdminProvisionUserRequest"/>.</summary>
public sealed class AdminProvisionUserRequestValidator : AbstractValidator<AdminProvisionUserRequest>
{
    /// <summary>Initializes a new instance of <see cref="AdminProvisionUserRequestValidator"/>.</summary>
    public AdminProvisionUserRequestValidator()
    {
        RuleFor(x => x.ExternalUserId)
            .NotEmpty().WithMessage("ExternalUserId is required.")
            .MaximumLength(100).WithMessage("ExternalUserId must be 100 characters or fewer.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Email must be a valid email address.")
            .MaximumLength(255).WithMessage("Email must be 255 characters or fewer.");

        RuleFor(x => x.DisplayName)
            .NotEmpty().WithMessage("DisplayName is required.")
            .MaximumLength(500).WithMessage("DisplayName must be 500 characters or fewer.");

        RuleFor(x => x.FirstName)
            .MaximumLength(100).WithMessage("FirstName must be 100 characters or fewer.");

        RuleFor(x => x.LastName)
            .MaximumLength(100).WithMessage("LastName must be 100 characters or fewer.");
    }
}
