# Developer Setup

This guide outlines how to set up a local development environment.

## Prerequisites

- Python 3.11+
- PostgreSQL (optional for local; SQLite works for quick tests)
- Docker (optional, for containerized development)

## Setup (Virtualenv)

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

3. Configure environment variables:
   - Copy `environments/dev.env` to a local file.
   - Set a strong `SECRET_KEY` and any DB settings required.

4. Apply migrations and run:
   ```bash
   python manage.py migrate
   python manage.py runserver
   ```

## Setup (Docker)

1. Start services:
   ```bash
   docker compose up --build
   ```

2. Run management commands:
   ```bash
   docker compose exec web python manage.py migrate
   docker compose exec web python manage.py createsuperuser
   ```

## Testing

- Run tests:
  ```bash
  pytest
  ```

- Run smoke tests only:
  ```bash
  pytest tests/smoke -v
  ```

## Pre-commit

- Install and run all hooks:
  ```bash
  pre-commit install
  pre-commit run --all-files
  ```
