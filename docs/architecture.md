# Architecture

This repo is a Django backend template intended to be copied into new projects.

## Stack

- Django 4.2 LTS + DRF
- Postgres (source of truth)
- Redis (cache / Celery broker)
- Celery workers for background tasks

## Settings

Settings live in `config/settings/` and are split into `base`, `dev`, `test`, `prod`.

Environment variables are loaded from `environments/base.env` if present.
