# Django Backend Template

A production-focused Django template with modular settings, Docker-based local development, and robust tooling for code quality, testing, and deployment.

## Features

- Custom user model (email-first)
- Modular settings: base, dev, test, prod
- Pre-commit hooks for formatting, linting, and hygiene
- Docker support for local development (PostgreSQL, Redis)
- CI-ready structure (lint, test, release)
- Optional: Django REST Framework and JWT authentication

## Project Structure

- `apps/` — Django apps (includes the custom user app)
- `config/settings/` — settings split by environment
- `docs/` — project documentation
- `environments/` — example environment files
- `requirements/` — dependency specifications
- `tests/` — unit, integration, and smoke tests
- `templates/` — HTML templates

## Quick Start (Local Development)

1. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate  # Windows
   source .venv/bin/activate  # macOS/Linux
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements/dev.txt
   ```

3. Configure environment:
   - Copy `environments/dev.env` to a local file and adjust values as needed.
   - Set a strong `SECRET_KEY`.

4. Apply migrations:
   ```bash
   python manage.py migrate
   ```

5. Run the server:
   ```bash
   python manage.py runserver
   ```

## Quick Start (Docker)

- Development:
  ```bash
  docker compose up --build
  ```

- Production-like:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up
