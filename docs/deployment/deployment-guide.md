# Deployment Guide

This guide describes how to deploy the service in a production-like environment using containers, environment variables, and a minimal application server configuration.

## Overview

- Container image built from the project Dockerfile.
- Application server: gunicorn (WSGI).
- Static assets served by Whitenoise or a reverse proxy/CDN.
- PostgreSQL and Redis as backing services.
- Error reporting and observability via Sentry (optional).

## Prerequisites

- Container registry access.
- Database (PostgreSQL) and cache (Redis).
- External reverse proxy or load balancer (e.g., Nginx, ingress).
- Environment variable management (e.g., secrets manager).

## Environment Variables

Common variables to set per environment:

- `DJANGO_SETTINGS_MODULE` (e.g., `config.settings.prod`)
- `SECRET_KEY` (strong, unique)
- `DEBUG` (`False` in production)
- `ALLOWED_HOSTS` (comma-separated)
- `DATABASE_URL` (e.g., `postgres://<user>:<password>@<host>:5432/<db>`)
- `REDIS_URL` (e.g., `redis://<host>:6379/0`)
- `SENTRY_DSN` (optional)
- `SECURE_PROXY_SSL_HEADER` (if behind a proxy)

Store secrets in a secret manager and inject at runtime.

## Build and Push Image

~~~ bash
  bash
# Build
docker build -t <your-registry>/<your-app>:.
# Log in (if required)
docker login <your-registry>
# Push
docker push <your-registry>/<your-app>:
~~~

## Database Migrations

Run migrations as a one-off task during deployment:

~~~ bash
  bash
docker run --rm
--env-file .env.production
<your-registry>/<your-app>:python manage.py migrate --noinput
~~~

Optionally collect static files at build or release time:

~~~ bash
  bash
docker run --rm
--env-file .env.production
-e DISABLE_COLLECTSTATIC=0
<your-registry>/<your-app>:python manage.py collectstatic --noinput
~~~

Note: For large/static-heavy deployments, consider building assets in CI and serving via a CDN or object storage.

## Application Server

Gunicorn is the default entrypoint. Typical production flags:

~~~ bash
  bash
# Example only; tune workers and timeouts for your workload
gunicorn config.wsgi:application
--bind 0.0.0.0:8000
--workers 3
--timeout 60
--graceful-timeout 30
--log-level info
--access-logfile '-'
--error-logfile '-'
~~~

- Workers: ~2–4 per CPU core for IO-bound apps (benchmark to choose).
- Increase `--timeout` cautiously for long-running requests, or move them to background jobs.

## Reverse Proxy

Place a reverse proxy in front to handle TLS, HTTP/2, compression, and caching.

- Enforce HTTPS and set HSTS.
- Forward client IP headers so Django can determine secure requests.
- Configure health endpoints (see below).

## Health Checks

Add lightweight endpoints for readiness and liveness (e.g., `/health/ready`, `/health/live`). A simple implementation
can check:

- App import and DB connectivity (readiness).
- Process responsiveness (liveness).

Configure your orchestrator to probe these endpoints periodically.

## Static and Media Files

- Whitenoise can serve static files directly from the application container for small to medium deployments.
- For high traffic or large assets, build and upload to a CDN or object storage; configure your proxy to serve them.
- Media files typically belong in object storage (S3/GCS) served behind a CDN.

## Observability

- Enable Sentry by setting `SENTRY_DSN`.
- Configure structured logging to stdout for aggregation by the platform.
- Add tracing/metrics exporters as needed.

## Rollout Strategy

- Use rolling or blue-green deployments to avoid downtime.
- Pre-run migrations that are backward-compatible before switching traffic.
- Keep `DEBUG=False` in production and confirm `ALLOWED_HOSTS` is correct.

## Zero-Downtime Migrations (Guidelines)

- For schema changes:
    - First deploy additive changes (new columns/tables).
    - Backfill data if needed.
    - Switch reads/writes to new structures.
    - Drop old columns in a later release.
- Avoid destructive changes in a single step.

## Sample Compose (Production-Like)

~~~ yaml
version: "3.8"

services:
  web:
    image: <your-registry>/<your-app>:<tag>
    command: gunicorn config.wsgi:application --bind 0.0.0.0:8000
    env_file:
      - .env.production
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data/

  redis:
    image: redis:7-alpine

volumes:
  postgres_data:
~~~

Note: Use managed PostgreSQL/Redis in real deployments; local containers are best for staging or demos.

## Security Checklist

- Confirm secrets are injected at runtime, not baked in.
- Set secure cookie flags and CSRF settings.
- Restrict inbound traffic at the network layer.
- Limit database credentials to least privilege.
- Rotate credentials and audit regularly.

## Troubleshooting

- App won’t start: check `DJANGO_SETTINGS_MODULE`, `SECRET_KEY`, and DB connectivity.
- Static files not served: ensure `collectstatic` ran and static root is readable; verify proxy configuration.
- 502s or timeouts: adjust worker count/timeouts; inspect database/query performance and external service latency.

## Next Steps

- Add readiness/liveness endpoints and integrate with the orchestrator.
- Configure CI to build and push images on commits to main.
- Automate migrations and cache invalidation on deploy.
