using ARA.Application.Clin;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="UpdateClinRequest"/>.</summary>
public sealed class UpdateClinRequestValidator : AbstractValidator<UpdateClinRequest>
{
    /// <summary>Initializes a new instance of <see cref="UpdateClinRequestValidator"/>.</summary>
    public UpdateClinRequestValidator()
    {
        RuleFor(x => x.ClinEntryId)
            .GreaterThan(0).WithMessage("ClinEntryId must be a positive integer.");

        RuleFor(x => x.ClinNumber)
            .NotEmpty().WithMessage("ClinNumber is required.");

        RuleFor(x => x.Cost)
            .GreaterThanOrEqualTo(0).WithMessage("Cost must be zero or greater.");

        RuleFor(x => x.Fee)
            .GreaterThanOrEqualTo(0).WithMessage("Fee must be zero or greater.");
    }
}
