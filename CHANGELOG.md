# Changelog

All notable changes to this template will be documented in this file.

The format is based on **Keep a Changelog**, and this project adheres to **Semantic Versioning**.

## [Unreleased]


## [0.0.3] - 2026-02-28
### Added
- Auto-discovery for `LOCAL_APPS` from the `/apps` folder (e.g. `apps.custom_user`, `apps.users`) to reduce manual settings edits.

## [0.0.2] - 2026-02-28
### Added
- Hybrid workflow documentation (Docker runtime + optional local venv for tooling).
- Docker-native Make targets (`d-migrate`, `d-test`, `d-startapp`, etc.).
- Entry scripts: `scripts/run_web.sh`, `scripts/run_worker.sh` for cleaner compose.

### Changed
- Dockerfile installs from pinned `requirements/dev.txt` instead of `dev.in` for reproducible builds.
- docker-compose now loads environment variables from `environments/base.env` and `environments/dev.env`.
- Added Postgres healthcheck and used it in `depends_on`.

### Fixed
- Changelog version formatting and typo.

## [0.0.1] - 2026-02-21
### Added
- Docker + Postgres + Redis scaffolding.
- Celery wiring and DB readiness script.
- Environments folder with example env files.

### Changed
- Standardised on Django 4.2 LTS.

### Fixed
- Requirements parsing issue