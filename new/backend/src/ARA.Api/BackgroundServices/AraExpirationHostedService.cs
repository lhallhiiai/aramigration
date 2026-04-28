using ARA.Domain.Repositories;

namespace ARA.Api.BackgroundServices;

/// <summary>
/// Background service that automatically transitions active ARAs to Expired status
/// when their expiration date has passed. Runs every hour.
/// Uses <see cref="IAraRepository.ExpireOverdueAsync"/> which calls the
/// <c>usp_AraExpireOverdue</c> stored procedure for atomic bulk updates.
/// </summary>
public sealed class AraExpirationHostedService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<AraExpirationHostedService> _logger;
    private static readonly TimeSpan Interval = TimeSpan.FromHours(1);

    /// <summary>Initializes a new instance of <see cref="AraExpirationHostedService"/>.</summary>
    public AraExpirationHostedService(
        IServiceScopeFactory scopeFactory,
        ILogger<AraExpirationHostedService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger       = logger;
    }

    /// <inheritdoc/>
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("ARA expiration service started. Checking every {Interval}.", Interval);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await using AsyncServiceScope scope = _scopeFactory.CreateAsyncScope();
                IAraRepository araRepository = scope.ServiceProvider.GetRequiredService<IAraRepository>();

                int expiredCount = await araRepository.ExpireOverdueAsync(stoppingToken);

                if (expiredCount > 0)
                {
                    _logger.LogInformation("Expired {Count} overdue ARA(s).", expiredCount);
                }
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during ARA expiration check. Will retry on next cycle.");
            }

            await Task.Delay(Interval, stoppingToken);
        }

        _logger.LogInformation("ARA expiration service stopped.");
    }
}
