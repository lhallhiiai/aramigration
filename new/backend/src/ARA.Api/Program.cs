using ARA.Api;
using ARA.Api.Middleware;
using ARA.Application;
using ARA.Application.Users;
using ARA.Infrastructure;
using FluentValidation;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Identity.Web;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

bool isDevAuthActive = builder.Environment.IsDevelopment()
    && string.IsNullOrWhiteSpace(builder.Configuration["AzureAd:TenantId"]);

if (isDevAuthActive)
{
    builder.Services.AddAuthentication(DevAuthenticationHandler.SchemeName)
        .AddScheme<AuthenticationSchemeOptions, DevAuthenticationHandler>(
            DevAuthenticationHandler.SchemeName, configureOptions: null);
}
else
{
    builder.Services.AddMicrosoftIdentityWebApiAuthentication(builder.Configuration);
}

builder.Services.AddAuthorization();

builder.Services.AddHealthChecks();

builder.Services.AddHttpContextAccessor();
builder.Services.AddInfrastructure();
builder.Services.AddApplicationServices();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

builder.Services.AddControllers();
builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly);

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

app.UseHttpsRedirection();
app.UseCors("AraFrontend");
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health");
app.MapControllers();

app.Run();
