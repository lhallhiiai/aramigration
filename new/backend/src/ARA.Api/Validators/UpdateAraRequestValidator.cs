using ARA.Application.Ara;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="UpdateAraRequest"/>.</summary>
public sealed class UpdateAraRequestValidator : AbstractValidator<UpdateAraRequest>
{
    /// <summary>Initializes a new instance of <see cref="UpdateAraRequestValidator"/>.</summary>
    public UpdateAraRequestValidator()
    {
        RuleFor(x => x.AraId)
            .GreaterThan(0).WithMessage("AraId must be a positive integer.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("CategoryId must be a positive integer.");

        RuleFor(x => x.ProgramManagerId)
            .GreaterThan(0).WithMessage("ProgramManagerId must be a positive integer.");

        RuleFor(x => x.ContractAdministratorId)
            .GreaterThan(0).WithMessage("ContractAdministratorId must be a positive integer.");

        RuleFor(x => x.ControllerId)
            .GreaterThan(0).WithMessage("ControllerId must be a positive integer.");
    }
}
