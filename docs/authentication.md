# Authentication

This project uses a **custom Django User model** (`apps/custom_user.CustomUser`) with **email-based authentication**
and JWT (JSON Web Tokens) for secure API access.

---

## Why Email-Based Authentication?

- **Email is unique** and user-friendly compared to usernames.
- Prevents migration headaches later when switching to email login.
- Works seamlessly with Django Admin and Django REST Framework.

---

## How It Works

- Login with `email` and `password`.
- `USERNAME_FIELD` is set to `email`.
- JWT provides two tokens:
    - **Access Token**: short-lived (default 60 minutes).
    - **Refresh Token**: long-lived (default 1 day).

---

## Endpoints

- **Register**
    - `POST /api/custom_user/register/`
- **Obtain Token**
    - `POST /api/custom_user/token/`
- **Refresh Token**
    - `POST /api/custom_user/token/refresh/`
- **Current User**
    - `GET /api/custom_user/me/`

See `apps/custom_user/tests.py` for working test examples.

```
