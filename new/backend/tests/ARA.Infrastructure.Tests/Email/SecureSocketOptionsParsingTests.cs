using ARA.Infrastructure;
using FluentAssertions;
using MailKit.Security;

namespace ARA.Infrastructure.Tests.Email;

/// <summary>
/// Verifies the SecureSocketOptions string-to-enum binding documented on
/// <c>SmtpOptions.SecureSocketOptions</c>: valid MailKit enum names map cleanly,
/// case-insensitive; anything else throws at startup with a helpful message
/// (per the on-prem pivot's "fail fast on operator typo" rule).
/// </summary>
public sealed class SecureSocketOptionsParsingTests
{
    [Theory]
    [InlineData("None", SecureSocketOptions.None)]
    [InlineData("Auto", SecureSocketOptions.Auto)]
    [InlineData("auto", SecureSocketOptions.Auto)]
    [InlineData("AUTO", SecureSocketOptions.Auto)]
    [InlineData("SslOnConnect", SecureSocketOptions.SslOnConnect)]
    [InlineData("StartTls", SecureSocketOptions.StartTls)]
    [InlineData("StartTlsWhenAvailable", SecureSocketOptions.StartTlsWhenAvailable)]
    public void ParseSecureSocketOptions_WithValidValue_ReturnsMatchingEnum(string input, SecureSocketOptions expected)
    {
        SecureSocketOptions result = InfrastructureServiceExtensions.ParseSecureSocketOptions(input);

        result.Should().Be(expected);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("invalid")]
    [InlineData("Start_Tls")]
    [InlineData("999")]
    public void ParseSecureSocketOptions_WithInvalidValue_ThrowsInvalidOperationWithAllowedValues(string input)
    {
        Action act = () => InfrastructureServiceExtensions.ParseSecureSocketOptions(input);

        act.Should().Throw<InvalidOperationException>()
            .Where(ex => ex.Message.Contains("Email:Smtp:SecureSocketOptions")
                && ex.Message.Contains("Allowed values:")
                && ex.Message.Contains("StartTls"));
    }
}
