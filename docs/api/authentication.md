# Authentication

This project supports an email-first user model. If API authentication is enabled, endpoints for login and token management are provided.

## Endpoints (if enabled)

- `POST /api/custom_user/register/` — register a new user
- `POST /api/custom_user/token/` — obtain an access token
- `POST /api/custom_user/token/refresh/` — refresh the token
- `GET /api/custom_user/me/` — retrieve the current authenticated user

## Notes

- Use `settings.AUTH_USER_MODEL` when referencing the user model.
- Ensure API dependencies are installed and settings are enabled before using these endpoints.
