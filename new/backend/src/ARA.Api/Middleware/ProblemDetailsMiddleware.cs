using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Middleware;

/// <summary>
/// Global exception handling middleware that converts unhandled exceptions into
/// RFC 7807 Problem Details responses. All caught exceptions are logged via ILogger
/// before being converted to a standard error response.
/// </summary>
public sealed class ProblemDetailsMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ProblemDetailsMiddleware> _logger;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    };

    /// <summary>Initializes a new instance of <see cref="ProblemDetailsMiddleware"/>.</summary>
    public ProblemDetailsMiddleware(RequestDelegate next, ILogger<ProblemDetailsMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    /// <summary>Invokes the middleware. Catches unhandled exceptions and returns Problem Details.</summary>
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
        {
            // Client disconnected — do not log as error
            context.Response.StatusCode = 499; // nginx convention for client closed request
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception processing {Method} {Path}.",
                context.Request.Method, context.Request.Path);

            await WriteProblemDetailsAsync(context, ex);
        }
    }

    private static async Task WriteProblemDetailsAsync(HttpContext context, Exception exception)
    {
        int statusCode = exception switch
        {
            UnauthorizedAccessException => (int)HttpStatusCode.Unauthorized,
            KeyNotFoundException => (int)HttpStatusCode.NotFound,
            ArgumentException => (int)HttpStatusCode.BadRequest,
            _ => (int)HttpStatusCode.InternalServerError,
        };

        ProblemDetails problemDetails = new()
        {
            Status = statusCode,
            Title = statusCode switch
            {
                400 => "Bad Request",
                401 => "Unauthorized",
                404 => "Not Found",
                _ => "An error occurred while processing your request.",
            },
            Detail = statusCode == 500
                ? "An internal server error has occurred. Please contact support if the problem persists."
                : exception.Message,
            Instance = context.Request.Path,
        };

        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/problem+json";
        await context.Response.WriteAsync(JsonSerializer.Serialize(problemDetails, JsonOptions));
    }
}
