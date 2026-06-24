# Django REST API Boilerplate

A lean, production-shaped Django 5.2 template for building REST APIs with Postgres.

---

## What's included

- **Django 5.2 LTS** — modular settings (`base`, `dev`, `test`, `prod`), ENV-based selection
- **uv** — fast dependency management; single `uv.lock` lockfile committed to the repo
- **DRF + simplejwt** — REST framework with JWT authentication out of the box
- **drf-spectacular** — OpenAPI 3 schema with Redoc and Swagger UI
- **ruff** — linting and formatting (replaces flake8 + black)
- **pre-commit** — ruff hooks on every commit + Conventional Commits validation on commit messages
- **pytest** — test runner with `pytest-django` and coverage
- **Sentry** — optional error monitoring, initialises only when `SENTRY_DSN` is set
- **Docker** — optional compose stack (web + Postgres 17); not required for local dev

---

## Auth endpoints

| Method | URL | Description |
|--------|-----|-------------|
| `POST` | `/auth/register/` | Register a new user; returns access + refresh tokens |
| `GET` | `/auth/me/` | Return the current authenticated user |
| `POST` | `/auth/token/` | Obtain a JWT access + refresh token pair |
| `POST` | `/auth/token/refresh/` | Exchange a refresh token for a new access token |

---

## Quick start (local)

**1. Create env files and generate a secret key**

```bash
make env-fix
make secret
```

**2. Create local Postgres databases**

```bash
createdb backend_boilerplate
createdb backend_boilerplate_test
```

**3. Install dependencies**

```bash
make install
```

**4. Apply migrations**

```bash
make migrate
```

**5. Run the dev server**

```bash
make runserver
```

The server starts at `http://127.0.0.1:8000`.

---

## Day-to-day commands

```bash
make lint          # ruff format --check + ruff check
make format        # ruff format + ruff check --fix
make test          # pytest (uses environments/test.env)
make shell-plus    # Django shell_plus (django-extensions)
```

Dependency management:

```bash
make lock          # recompile uv.lock from pyproject.toml
make upgrade       # upgrade all deps to latest allowed versions and relock
```

---

## Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/).
A `commit-msg` hook enforces this locally — install it once after cloning:

```bash
uv run pre-commit install
uv run pre-commit install --hook-type commit-msg
```

**Allowed types**

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change with no behaviour change |
| `perf` | Performance improvement |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `style` | Formatting, whitespace |
| `chore` | Maintenance, dependency bumps |
| `build` | Build system or tooling |
| `ci` | CI configuration |
| `revert` | Reverts a previous commit |

Scope is optional, kebab-case. Subject: imperative mood, lowercase, no trailing period, ≤ 72 chars.

```
feat(custom-user): add phone number field to user model
chore: upgrade postgres image to 17
```

---

## Docker (optional)

```bash
make docker-up     # build and start web + postgres
make d-migrate     # run migrations inside the web container
make d-test        # run pytest inside the web container
```

---

## API docs

Start the server then open:

| URL | Description |
|-----|-------------|
| `/api/schema/` | Raw OpenAPI 3 schema (YAML) |
| `/api/docs/` | Redoc — human-readable reference |
| `/api/swagger/` | Swagger UI — interactive explorer |

---

## CI

GitHub Actions runs two jobs on every pull request and push to `main`/`master`:

- **lint** — `uv sync --dev --frozen`, then `pre-commit run --all-files`
- **test** — pytest with a live Postgres 17 service, matrix across Python 3.12 and 3.13

---

## Batteries

This template ships lean. Add Celery, Redis, S3, or other infrastructure as
project-specific compose profiles when the project needs them — no refactoring required.
