using ARA.Application.Delegation;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="CreateDelegationRequest"/>.</summary>
public sealed class CreateDelegationRequestValidator : AbstractValidator<CreateDelegationRequest>
{
    /// <summary>Initializes a new instance of <see cref="CreateDelegationRequestValidator"/>.</summary>
    public CreateDelegationRequestValidator()
    {
        RuleFor(x => x.DelegateeUserId)
            .GreaterThan(0).WithMessage("DelegateeUserId must be a positive integer.");

        RuleFor(x => x.EndDate)
            .GreaterThan(x => x.StartDate)
            .WithMessage("EndDate must be after StartDate.");
    }
}
