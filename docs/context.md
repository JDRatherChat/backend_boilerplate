# Developer Context for AI Assistants

## Version

- Current: **0.1.0** (2025-07-29)

## Primary Goals

- Lightweight but production-ready Django backend
- Modular and easy to extend
- Secure, reproducible, and team-friendly
- CI/CD ready with GitHub Actions
- Pre-commit hooks for consistent code quality

## Included Features

- Modular `settings/` (base, dev, prod, restframework, logging)
- GitHub Actions: linting + tests + release pipeline
- Makefile: setup, install, runserver, migrations, format, lint, test, test-fast, commit, ship
- Pre-commit hooks: black, isort, flake8, YAML and whitespace checks
- Example apps:
  - `core`: template + DRF healthcheck views
  - `custom_user`: email-based authentication + JWT
- SQLite by default, Postgres optional

## Updating Pre-commit Hooks

If pre-commit fails due to outdated hook versions:

```bash
pre-commit autoupdate
pre-commit install
````
