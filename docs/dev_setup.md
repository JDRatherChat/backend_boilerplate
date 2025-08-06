# Developer Setup

This guide explains how to configure your environment for the Cookiecutter Django Boilerplate.

## Virtual Environment

- This boilerplate expects a virtual environment located at `.venv/`.
- On Windows, executables are in `.venv/Scripts/`.
- On macOS/Linux, they are in `.venv/bin/`.

## First Run Setup

1. Install dependencies:
   ```bash
   make setup


2. Generate a secret key and add to your environment file:

   ```bash
   make secret envfile=environments/dev.env
   ```
3. Create initial migrations:

   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```
4. Start the development server:

   ```bash
   make runserver
   ```

## Code Style

* Right margin: 88 characters
* 4-space indents
* Tools:

    * **Black**: `make format`
    * **isort**: `make format`
    * **Flake8**: `make lint`
    * **pytest**: `make test` / `make test-fast`

## Git Workflow

* Commit with quality checks:

  ```bash
  make commit m="Your message"
  ```
* Release new version:

  ```bash
  make ship
  ```
