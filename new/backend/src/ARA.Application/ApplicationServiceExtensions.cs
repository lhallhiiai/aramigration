using ARA.Application.Approval;
using ARA.Application.Ara;
using ARA.Application.Ara.Sections;
using ARA.Application.Category;
using ARA.Application.Clin;
using ARA.Application.Delegation;
using ARA.Application.Document;
using ARA.Application.JobTitle;
using ARA.Application.RejectionReason;
using ARA.Application.Users;
using Microsoft.Extensions.DependencyInjection;

namespace ARA.Application;

/// <summary>
/// Registers all Application layer services with the dependency injection container.
/// Call <see cref="AddApplicationServices"/> from <c>Program.cs</c>.
/// </summary>
public static class ApplicationServiceExtensions
{
    /// <summary>Adds all Application layer service implementations.</summary>
    /// <param name="services">The service collection to configure.</param>
    /// <returns>The same <paramref name="services"/> for chaining.</returns>
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<ICategoryService, CategoryService>();
        services.AddScoped<IJobTitleService, JobTitleService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IAraService, AraService>();
        services.AddScoped<IAraPmSectionService, AraPmSectionService>();
        services.AddScoped<IAraControllerSectionService, AraControllerSectionService>();
        services.AddScoped<IClinEntryService, ClinEntryService>();
        services.AddScoped<IDocumentService, DocumentService>();
        services.AddScoped<IApprovalRecordService, ApprovalRecordService>();
        services.AddScoped<IApprovalRoutingService, ApprovalRoutingService>();
        services.AddScoped<IDelegationService, DelegationService>();
        services.AddScoped<IRejectionReasonService, RejectionReasonService>();

        return services;
    }
}
