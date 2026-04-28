# =============================================================================
# ARA Backend — Multi-stage Docker Build
# Target: Azure Container Apps
# =============================================================================

FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

# Copy solution and project files for layer caching
COPY ARA.slnx .
COPY src/ARA.Api/ARA.Api.csproj src/ARA.Api/
COPY src/ARA.Application/ARA.Application.csproj src/ARA.Application/
COPY src/ARA.Domain/ARA.Domain.csproj src/ARA.Domain/
COPY src/ARA.Infrastructure/ARA.Infrastructure.csproj src/ARA.Infrastructure/

# Restore dependencies (cached unless .csproj files change)
RUN dotnet restore src/ARA.Api/ARA.Api.csproj

# Copy remaining source code
COPY . .

# Publish release build
RUN dotnet publish src/ARA.Api/ARA.Api.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# =============================================================================
# Runtime image
# =============================================================================

FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS runtime
WORKDIR /app

# Non-root user for security
RUN adduser --disabled-password --gecos "" appuser
USER appuser

COPY --from=build /app/publish .

# Azure Container Apps injects PORT env var
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Health check for ACA probes
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "ARA.Api.dll"]
