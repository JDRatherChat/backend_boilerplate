# Django Backend Boilerplate (API-first, Postgres-first)

A lean, production-shaped Django template for building **REST APIs**.

- **Postgres-first** in all environments (dev/test/prod)
- **ENV-based settings selection**: `ENV=dev`, `ENV=test`, `ENV=prod`
- **API docs** via drf-spectacular (Redoc + Swagger UI)
- **Sentry** optional (initialises only when `SENTRY_DSN` is set)
- **Deterministic tooling**: ruff + black + pytest + pre-commit
- **CI scaffolding**: GitHub Actions (lint + tests with Postgres, Python 3.12/3.13)

Docker is supported, but **optional** (web + Postgres only) to keep the default template lean.

---

## What’s included

- Modular settings: `config.settings.{base,dev,test,prod}`
- Env loader: `environments/base.env` + `environments/<ENV>.env`
- Postgres (local) + optional Docker compose (web + Postgres)
- `scripts/wait_for_db.py` for reliable DB readiness
- OpenAPI schema + docs:
  - `/api/schema/`
  - `/api/docs/` (Redoc)
  - `/api/swagger/` (Swagger UI)

---

## Quick start (local)

### 1) Create env files

```bash
make env-fix
make secret
```

### 2) Create local databases

```bash
createdb backend_boilerplate
createdb backend_boilerplate_test
```

### 3) Install deps + migrate

```bash
make install
make migrate ENV=dev
```

### 4) Run

```bash
make runserver ENV=dev
```

---

## Optional: Docker runtime

```bash
make docker-up
```

Run migrations in Docker:

```bash
make d-migrate ENV=dev_docker
```

---

## Day-to-day

### Lint / format

```bash
make lint
make format
```

### Tests

```bash
make test
```

### API docs

Once the server is running:

- OpenAPI schema: `http://127.0.0.1:8000/api/schema/`
- Redoc: `http://127.0.0.1:8000/api/docs/`
- Swagger UI: `http://127.0.0.1:8000/api/swagger/`

### Sentry (optional)

Sentry is initialised only when `SENTRY_DSN` is set.

---

## CI

GitHub Actions runs:
- `pre-commit run --all-files`
- `pytest` against Postgres (Python 3.12 and 3.13)

---

## Batteries (when you need them)

This template intentionally ships **lean**. When you need background workers, caching, or object storage, add them as a project-specific profile (Celery/Redis/S3) without refactoring your core API.
