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
- `docs/` — project documentation (MkDocs)
- `environments/` — example environment files
- `requirements/` — dependency specifications
- `tests/` — unit, integration, and smoke tests
- `templates/` — HTML templates

## Quick Start

For full setup instructions, see:

- Getting Started: Installation — docs/getting-started/installation.md

Minimal local workflow:

```bash
make setup
make secret
make migrate
make runserver
```

Docker workflow (summary):

```bash
docker compose up --build
```

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

Docs are built with MkDocs. Local preview:

```bash
make docs-serve
```

## Contributing

See docs/contributing.md for guidance. Use:## Contributing

```bash
pre-commit install
pre-commit run --all-files
```
