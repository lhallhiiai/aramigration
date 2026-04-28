using ARA.Application.Ara.Sections;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="SaveAraPmSectionRequest"/>.</summary>
public sealed class SaveAraPmSectionRequestValidator : AbstractValidator<SaveAraPmSectionRequest>
{
    /// <summary>Initializes a new instance of <see cref="SaveAraPmSectionRequestValidator"/>.</summary>
    public SaveAraPmSectionRequestValidator()
    {
        // All fields are optional to support partial saves across sessions.
    }
}
