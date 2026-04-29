using ARA.Application.Email;
using ARA.Infrastructure;
using ARA.Infrastructure.Email;
using FluentAssertions;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace ARA.Infrastructure.Tests.Email;

/// <summary>
/// Verifies the DI fallback rule from SHIP_PLAN Item 8b.1: when <c>Email:Smtp:Host</c>
/// is null / empty / whitespace, <see cref="LoggingEmailService"/> is registered;
/// any non-empty value selects <see cref="M365SmtpEmailService"/>. Selection is
/// startup-time, not per-request.
/// </summary>
public sealed class InfrastructureEmailRegistrationTests
{
    [Fact]
    public void AddInfrastructure_WithEmptySmtpHost_RegistersLoggingEmailService()
    {
        ServiceDescriptor descriptor = ResolveEmailServiceDescriptor(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = string.Empty,
        });

        descriptor.ImplementationType.Should().Be(typeof(LoggingEmailService));
    }

    [Fact]
    public void AddInfrastructure_WithMissingSmtpSection_RegistersLoggingEmailService()
    {
        ServiceDescriptor descriptor = ResolveEmailServiceDescriptor([]);

        descriptor.ImplementationType.Should().Be(typeof(LoggingEmailService));
    }

    [Fact]
    public void AddInfrastructure_WithWhitespaceSmtpHost_RegistersLoggingEmailService()
    {
        ServiceDescriptor descriptor = ResolveEmailServiceDescriptor(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = "   ",
        });

        descriptor.ImplementationType.Should().Be(typeof(LoggingEmailService));
    }

    [Fact]
    public void AddInfrastructure_WithConfiguredSmtpHost_RegistersM365SmtpEmailService()
    {
        ServiceDescriptor descriptor = ResolveEmailServiceDescriptor(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = "smtp.relay.internal",
            ["Email:Smtp:Port"] = "25",
            ["Email:Smtp:SecureSocketOptions"] = "Auto",
            ["Email:FromAddress"] = "ara@hii-tsd.com",
        });

        // SMTP path uses an implementation factory; verify the factory exists and there's no
        // direct ImplementationType (which would mean the LoggingEmailService path was taken).
        descriptor.ImplementationFactory.Should().NotBeNull();
        descriptor.ImplementationType.Should().BeNull();

        // Also verify the IMailKitSmtpClient is registered when SMTP is selected — its
        // presence is the second-order signal that the SMTP branch ran.
        ServiceCollection services = new();
        services.AddInfrastructure(BuildConfiguration(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = "smtp.relay.internal",
            ["Email:Smtp:Port"] = "25",
            ["Email:Smtp:SecureSocketOptions"] = "Auto",
            ["Email:FromAddress"] = "ara@hii-tsd.com",
        }));
        services.Should().Contain(d => d.ServiceType == typeof(IMailKitSmtpClient));
    }

    [Fact]
    public void AddInfrastructure_WithSmtpHostButMissingPort_ThrowsAtStartup()
    {
        Action act = () => new ServiceCollection().AddInfrastructure(BuildConfiguration(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = "smtp.relay.internal",
            ["Email:FromAddress"] = "ara@hii-tsd.com",
        }));

        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*Email:Smtp:Port*");
    }

    [Fact]
    public void AddInfrastructure_WithSmtpHostButMissingFromAddress_ThrowsAtStartup()
    {
        Action act = () => new ServiceCollection().AddInfrastructure(BuildConfiguration(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = "smtp.relay.internal",
            ["Email:Smtp:Port"] = "25",
        }));

        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*Email:FromAddress*");
    }

    [Fact]
    public void AddInfrastructure_WithSmtpHostButInvalidSecureSocketOptions_ThrowsAtStartup()
    {
        Action act = () => new ServiceCollection().AddInfrastructure(BuildConfiguration(new Dictionary<string, string?>
        {
            ["Email:Smtp:Host"] = "smtp.relay.internal",
            ["Email:Smtp:Port"] = "25",
            ["Email:Smtp:SecureSocketOptions"] = "TotallyMadeUp",
            ["Email:FromAddress"] = "ara@hii-tsd.com",
        }));

        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*SecureSocketOptions*TotallyMadeUp*");
    }

    private static IConfiguration BuildConfiguration(Dictionary<string, string?> settings) =>
        new ConfigurationBuilder().AddInMemoryCollection(settings).Build();

    private static ServiceDescriptor ResolveEmailServiceDescriptor(Dictionary<string, string?> settings)
    {
        ServiceCollection services = new();
        services.AddInfrastructure(BuildConfiguration(settings));
        return services.Single(d => d.ServiceType == typeof(IEmailService));
    }
}
