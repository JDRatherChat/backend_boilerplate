# Django Cookiecutter Boilerplate 🚀

A lightweight but production-ready Django boilerplate, designed for rapid project setup with clean defaults, modular
settings, and built-in authentication.

---

## Features

- ✅ **Custom User Model** with email-based authentication
- ✅ **JWT Authentication** ready with `djangorestframework-simplejwt`
- ✅ **DRF Example** healthcheck endpoint
- ✅ **Makefile** for easy commands (`make setup`, `make test`, `make ship`)
- ✅ **Pre-commit hooks** (black, isort, flake8, YAML, whitespace checks)
- ✅ **CI/CD with GitHub Actions** (linting, tests, releases)
- ✅ **SQLite by default**; Postgres optional for staging/prod
- ✅ **Docker support** for Postgres deployments

---

## Project Structure

- `apps/` — project apps including the custom user app
- `config/settings/` — modular Django settings
- `docs/` — project documentation and guides
- `environments/` — sample environment variable files
- `requirements/` — Python dependency specifications
- `templates/` — HTML templates

---

## Quick Start

1. **Clone the template**
   ```bash
   git clone https://github.com/<your-org>/backend_boilerplate.git
   cd backend_boilerplate
   ```

2. **Create your environment**
   ```bash
   make setup
   ```
   This command creates a `.venv/` directory and installs dependencies.
   Activate the virtual environment:
   
   ```bash
   source .venv/bin/activate      # macOS/Linux
   .venv\Scripts\activate       # Windows
   ```

3. **Generate a secret key**

   The default environment file is `environments/dev.env`. Run this after
   setting up your project to replace the placeholder `SECRET_KEY`:

   ```bash
   make secret envfile=environments/dev.env
   ```

4. **Apply initial migrations**

   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

5. **Run the development server**

   ```bash
   make runserver
   ```

---

## Custom User Model

This project defines a custom user model at `apps.custom_user.CustomUser` and sets
`AUTH_USER_MODEL` accordingly. Use `settings.AUTH_USER_MODEL` when creating
relationships to the user (for example,
`models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)`). You can
manage accounts either via the authentication API endpoints or through standard
Django commands like `python manage.py createsuperuser`.

---

## Makefile Commands

* `make setup` — create venv and install dependencies
* `make install` — install/update requirements
* `make runserver` — start development server
* `make makemigrations` — create new migrations
* `make migrate` — apply migrations
* `make shell` — open Django shell\_plus
* `make format` — run black + isort
* `make lint` — run flake8
* `make test` — run tests with coverage
* `make test-fast` — run tests without coverage
* `make commit m="message"` — run checks + commit
* `make ship` — bump version & push release

---

## Authentication Endpoints

* `POST /api/custom_user/register/` — register new user
* `POST /api/custom_user/token/` — obtain JWT token
* `POST /api/custom_user/token/refresh/` — refresh token
* `GET /api/custom_user/me/` — current user

See [Authentication Docs](docs/authentication.md) for details.

---

## Development Guides

* [Authentication](docs/authentication.md)
* [Contributing](docs/contributing.md)
* [Environments](docs/environments.md)
* [Developer Setup](docs/dev_setup.md)

---

## CI/CD

* **Linting**: `.github/workflows/lint.yml`
* **Tests**: `.github/workflows/test.yml`
* **Release**: `.github/workflows/ship.yml`

---

## Version

* Current: **0.1.0**

