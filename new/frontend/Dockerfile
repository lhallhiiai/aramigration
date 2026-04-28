# =============================================================================
# ARA Frontend — Multi-stage Docker Build
# Target: Azure Container Apps (nginx serving static files)
# =============================================================================

FROM node:24-alpine AS build
WORKDIR /app

# Copy package files for layer caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build
COPY . .

# Build-time env vars (set via --build-arg in CI)
ARG VITE_API_URL=/api
ARG VITE_OKTA_ISSUER
ARG VITE_OKTA_CLIENT_ID

RUN npm run build

# =============================================================================
# Runtime image — nginx serving static SPA
# =============================================================================

FROM nginx:alpine AS runtime

# Copy built assets
COPY --from=build /app/dist /usr/share/nginx/html

# SPA routing: all paths fall back to index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -q --spider http://localhost:80/ || exit 1
