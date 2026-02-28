## Environment files

This project loads environment variables from:

- `environments/base.env` (shared defaults / secrets)
- `environments/dev.env` (development overrides)

For local development:

1. Copy `base.env.example` to `base.env`
2. Copy `dev.env.example` to `dev.env`
3. Run `make secret` to generate a strong `SECRET_KEY` (won’t overwrite existing)

Never commit `*.env` files containing secrets.

