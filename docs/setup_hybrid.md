# Hybrid Setup Guide (Postgres-first: local + optional Docker)

This template supports a **Postgres-first** development workflow:

- **Local**: run Django with your local venv, connecting to a **local Postgres** instance.
- **Docker (optional)**: run the runtime stack (**web + Postgres**) in containers.

You can run migrations/tests either locally or inside Docker.

---

## 1) Prereqs

- Postgres 14+ installed locally **or** Docker Desktop installed & running
- Python 3.12+ installed locally
- `make` (recommended)

Verify:
```bash
psql --version
python --version
```

---

## 2) Create env files

```bash
make env-fix
make secret
```

This creates (if missing):
- `environments/base.env`
- `environments/dev.env` (local Postgres)
- `environments/dev_docker.env` (Docker Postgres)
- `environments/test.env`

---

## 3A) Local (recommended for day-to-day)

1) Create the local databases:

```bash
createdb backend_boilerplate
createdb backend_boilerplate_test
```

2) Install deps + run migrations:

```bash
make install
make migrate ENV=dev
```

3) Run the server:

```bash
make runserver ENV=dev
```

---

## 3B) Docker (optional)

```bash
make docker-up
```

This starts:
- `db` (Postgres)
- `web` (Django)

Open:
- http://localhost:8000

---

## 4) Run Django commands in Docker

Migrations:
```bash
make d-migrate ENV=dev_docker
```

Create a superuser:
```bash
make d-manage ENV=dev_docker ARGS="createsuperuser"
```

Shell:
```bash
make d-shell
```

---

## 5) Optional: local venv for IDE + tooling

```bash
make install
make lint
make test
```

---

## Windows note

If you’re on Windows and don’t have GNU Make, you can still run:

```powershell
$env:ENV="dev"
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py runserver
```
