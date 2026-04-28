using ARA.Api;
using ARA.Api.Middleware;
using ARA.Application;
using ARA.Application.Users;
using ARA.Infrastructure;
using ARA.Infrastructure.HealthChecks;
using Azure.Identity;
using FluentValidation;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

string? keyVaultUri = builder.Configuration["KeyVaultUri"];
if (!string.IsNullOrWhiteSpace(keyVaultUri))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUri),
        new DefaultAzureCredential());
}

bool isDevAuthActive = builder.Environment.IsDevelopment()
    && string.IsNullOrWhiteSpace(builder.Configuration["Okta:Issuer"]);

if (isDevAuthActive)
{
    builder.Services.AddAuthentication(DevAuthenticationHandler.SchemeName)
        .AddScheme<AuthenticationSchemeOptions, DevAuthenticationHandler>(
            DevAuthenticationHandler.SchemeName, configureOptions: null);
}
else
{
    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.Authority = builder.Configuration["Okta:Issuer"];
            options.Audience = builder.Configuration["Okta:Audience"];
        });
}

builder.Services.AddAuthorization();

// Application Insights. The connection string lives at
// "ApplicationInsights:ConnectionString" — in production this key is sourced
// from Key Vault by the AddAzureKeyVault call above, with no source-controlled
// fallback. When the key is empty (typical local dev), the SDK no-ops and
// telemetry simply isn't published.
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
});

// Typed HttpClient for the Okta OIDC discovery probe — short timeout so a
// hung Okta endpoint can't block the readiness probe.
builder.Services.AddHttpClient(OktaMetadataHealthCheck.HttpClientName, client =>
{
    client.Timeout = TimeSpan.FromSeconds(5);
});

builder.Services.AddHealthChecks()
    .AddCheck<SqlConnectivityHealthCheck>("sql", tags: ["ready"])
    .AddCheck<KeyVaultHealthCheck>("keyvault", tags: ["ready"])
    .AddCheck<OktaMetadataHealthCheck>("okta", tags: ["ready"]);

builder.Services.AddHttpContextAccessor();
builder.Services.AddInfrastructure();
builder.Services.AddApplicationServices();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

builder.Services.AddControllers();
builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly);
builder.Services.AddHostedService<ARA.Api.BackgroundServices.AraExpirationHostedService>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AraFrontend", policy =>
    {
        policy.WithOrigins(builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? [])
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

WebApplication app = builder.Build();

app.UseMiddleware<ARA.Api.Middleware.ProblemDetailsMiddleware>();
app.UseHttpsRedirection();
app.UseCors("AraFrontend");
app.UseAuthentication();
app.UseMiddleware<JitUserProvisioningMiddleware>();
app.UseAuthorization();

// Liveness: cheap — process is up. No dependency calls. K8s/Container Apps
// uses this to decide whether to restart the container.
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = static _ => false,
});

// Readiness: real dependency checks (SQL, Key Vault, Okta discovery).
// Returns 200 when Healthy, 200 with degraded JSON when any check is Degraded,
// 503 when any check is Unhealthy. Fronting load balancer / probe should
// exclude the instance from rotation on 503.
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = static r => r.Tags.Contains("ready"),
    ResponseWriter = HealthCheckResponseWriter.WriteJsonResponse,
});

app.MapControllers();

app.Run();
