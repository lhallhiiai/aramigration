using ARA.Application.Ara;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="CreateAraRequest"/>.</summary>
public sealed class CreateAraRequestValidator : AbstractValidator<CreateAraRequest>
{
    /// <summary>Initializes a new instance of <see cref="CreateAraRequestValidator"/>.</summary>
    public CreateAraRequestValidator()
    {
        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("CategoryId must be a positive integer.");

        RuleFor(x => x.ProgramManagerId)
            .GreaterThan(0).WithMessage("ProgramManagerId must be a positive integer.");

        RuleFor(x => x.ContractAdministratorId)
            .GreaterThan(0).WithMessage("ContractAdministratorId must be a positive integer.");

        RuleFor(x => x.ControllerId)
            .GreaterThan(0).WithMessage("ControllerId must be a positive integer.");

        RuleFor(x => x.AmountTotal)
            .GreaterThan(0).WithMessage("AmountTotal must be greater than zero.");

        RuleFor(x => x.OmsNumber)
            .NotEmpty().When(x => x.IsEarlyStart)
            .WithMessage("OmsNumber is required for Early Start ARAs.");

        RuleFor(x => x.ContractNumber)
            .NotEmpty().When(x => !x.IsEarlyStart)
            .WithMessage("ContractNumber is required for Non-Early Start ARAs.");
    }
}
