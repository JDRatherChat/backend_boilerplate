# Environments

This project uses environment-specific settings modules and environment variables.

## Settings Modules

- `config.settings.dev` — development defaults
- `config.settings.test` — testing configuration
- `config.settings.prod` — production configuration

Select the module with `DJANGO_SETTINGS_MODULE`.

## Common Environment Variables

- `SECRET_KEY` — Django secret key
- `DEBUG` — `True` or `False`
- `ALLOWED_HOSTS` — comma-separated hostnames
- `DATABASE_URL` — e.g., `postgres://<user>:<password>@<host>:5432/<db>`
- `REDIS_URL` — e.g., `redis://<host>:6379/0`
- `SENTRY_DSN` — DSN for error reporting (optional)

## Local Development

- Copy `environments/dev.env` and adjust values.
- Do not commit local secrets to version control.

## Production

- Use strong, unique secrets and disable `DEBUG`.
- Set restrictive `ALLOWED_HOSTS`.
- Configure database and cache services.
