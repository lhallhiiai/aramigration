using ARA.Application.Ara.Sections;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="SaveAraControllerSectionRequest"/>.</summary>
public sealed class SaveAraControllerSectionRequestValidator : AbstractValidator<SaveAraControllerSectionRequest>
{
    /// <summary>Initializes a new instance of <see cref="SaveAraControllerSectionRequestValidator"/>.</summary>
    public SaveAraControllerSectionRequestValidator()
    {
        RuleFor(x => x.BurnRate)
            .GreaterThanOrEqualTo(0)
            .When(x => x.BurnRate.HasValue)
            .WithMessage("BurnRate must be zero or greater.");
    }
}
