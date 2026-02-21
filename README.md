# Django Backend Template

A production-focused Django template with modular settings, Docker-based local development, and robust tooling for code
quality, testing, and deployment.

## Features

- Custom user model (email-first)
- Modular settings: base, dev, test, prod
- Pre-commit hooks for formatting, linting, and hygiene
- Black (formatting) + Ruff (linting and import sorting)
- Docker support for local development (PostgreSQL, Redis)
- CI-ready structure (lint, test, release)
- Optional: Django REST Framework and JWT authentication

## Project Structure

- `apps/` — Django apps
- `config/settings/` — settings split by environment
- `docs/` — project documentation (markdown)
- `environments/` — local env files (examples committed; secrets not committed)
- `requirements/` — dependency specifications
- `tests/` — unit, integration, and smoke tests
- `templates/` — HTML templates

## Quick Start (local, no Docker)

```bash
make setup
make secret
make migrate
make runserver
```

## Quick Start (Docker: Postgres + Redis)

```bash
docker compose up --build
```

The compose stack runs:
- Django web: http://localhost:8000
- Postgres: localhost:5432
- Redis: localhost:6379

## Development Shortcuts

- Start dev stack (containers, migrate, runserver):

```bash
make dev
```

- Format and lint:

```bash

make format # Black
make lint # Ruff
make lint-fix # Ruff with autofix
```

- Tests:

```bash
make test # with coverage
make test-fast # quick run
make smoke # smoke tests
```

## Documentation

See `docs/` for architecture, security, and development workflow notes.

## Contributing

This template is intended to be copied into new projects.

