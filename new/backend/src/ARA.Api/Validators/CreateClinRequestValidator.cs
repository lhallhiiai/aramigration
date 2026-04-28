using ARA.Application.Clin;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="CreateClinRequest"/>.</summary>
public sealed class CreateClinRequestValidator : AbstractValidator<CreateClinRequest>
{
    /// <summary>Initializes a new instance of <see cref="CreateClinRequestValidator"/>.</summary>
    public CreateClinRequestValidator()
    {
        RuleFor(x => x.ClinNumber)
            .NotEmpty().WithMessage("ClinNumber is required.");

        RuleFor(x => x.Cost)
            .GreaterThanOrEqualTo(0).WithMessage("Cost must be zero or greater.");

        RuleFor(x => x.Fee)
            .GreaterThanOrEqualTo(0).WithMessage("Fee must be zero or greater.");
    }
}
