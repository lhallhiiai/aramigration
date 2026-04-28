using System.Text.Json;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace ARA.Api;

/// <summary>
/// Renders <see cref="HealthReport"/> instances as JSON for the
/// <c>/health/ready</c> endpoint. The shape is intentionally small and
/// stable — operations dashboards and uptime probes parse it.
/// </summary>
public static class HealthCheckResponseWriter
{
    /// <summary>
    /// Writes a JSON body with the overall status and per-check details.
    /// Use as <see cref="HealthCheckOptions.ResponseWriter"/>.
    /// </summary>
    public static Task WriteJsonResponse(HttpContext context, HealthReport report)
    {
        context.Response.ContentType = "application/json; charset=utf-8";

        var payload = new
        {
            status = report.Status.ToString(),
            totalDurationMs = report.TotalDuration.TotalMilliseconds,
            results = report.Entries.ToDictionary(
                kvp => kvp.Key,
                kvp => new
                {
                    status = kvp.Value.Status.ToString(),
                    description = kvp.Value.Description,
                    durationMs = kvp.Value.Duration.TotalMilliseconds,
                    error = kvp.Value.Exception?.Message,
                }),
        };

        return JsonSerializer.SerializeAsync(
            context.Response.Body,
            payload,
            new JsonSerializerOptions { WriteIndented = false });
    }
}
