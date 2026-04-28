using ARA.Application.Document;
using FluentValidation;

namespace ARA.Api.Validators;

/// <summary>FluentValidation rules for <see cref="CreateDocumentRequest"/>.</summary>
public sealed class CreateDocumentRequestValidator : AbstractValidator<CreateDocumentRequest>
{
    /// <summary>Maximum allowed file size in bytes (5 MB).</summary>
    private const long MaxFileSizeBytes = 5_242_880;

    /// <summary>Initializes a new instance of <see cref="CreateDocumentRequestValidator"/>.</summary>
    public CreateDocumentRequestValidator()
    {
        RuleFor(x => x.FileName)
            .NotEmpty().WithMessage("FileName is required.")
            .Must(name => name != null && name.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase))
            .WithMessage("FileName must end with .pdf.");

        RuleFor(x => x.StoragePath)
            .NotEmpty().WithMessage("StoragePath is required.");

        RuleFor(x => x.FileSizeBytes)
            .LessThanOrEqualTo(MaxFileSizeBytes)
            .When(x => x.FileSizeBytes.HasValue)
            .WithMessage($"FileSizeBytes must not exceed {MaxFileSizeBytes} bytes (5 MB).");
    }
}
