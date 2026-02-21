using ARA.Domain.Repositories;
using ARA.Infrastructure.Database;
using ARA.Infrastructure.Repositories;
using Microsoft.Extensions.DependencyInjection;

namespace ARA.Infrastructure;

/// <summary>
/// Registers all Infrastructure layer services with the dependency injection container.
/// Call <see cref="AddInfrastructure"/> from <c>Program.cs</c>.
/// </summary>
public static class InfrastructureServiceExtensions
{
    /// <summary>
    /// Adds the database connection factory and all repository implementations.
    /// </summary>
    /// <param name="services">The service collection to configure.</param>
    /// <returns>The same <paramref name="services"/> for chaining.</returns>
    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        services.AddSingleton<IDbConnectionFactory, SqlConnectionFactory>();

        services.AddScoped<IAraRepository, AraRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IApprovalRecordRepository, ApprovalRecordRepository>();
        services.AddScoped<IDocumentRepository, DocumentRepository>();
        services.AddScoped<IClinEntryRepository, ClinEntryRepository>();
        services.AddScoped<ICategoryRepository, CategoryRepository>();
        services.AddScoped<IJobTitleRepository, JobTitleRepository>();

        return services;
    }
}
