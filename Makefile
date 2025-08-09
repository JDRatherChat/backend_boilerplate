SHELL := /bin/bash

# === Setup commands === #

venv:  # Create and activate a virtual environment
	@echo "Creating virtual environment..."
	python -m venv .venv
	@echo "Activating virtual environment..."
	source .venv/Scripts/activate
	@echo "Installing pip-tools..."
	pip install pip-tools

requirements:  # Compile requirements using pip-tools
	@echo "Compiling requirements..."
	pip-compile requirements/base.in -o base.txt
	@echo "Compiling dev requirements..."
	pip-compile requirements/dev.in -o dev.txt
	pip install -r dev.txt

secret:  # Generate a new Django SECRET_KEY and add it to the dev.env
	@echo "Generating new Django SECRET_KEY..."
	@SECRET=$$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())") && \
	echo "SECRET_KEY=$$SECRET" >> environments/dev.env
	echo "✓ SECRET_KEY added to development environment..."


# === Common Python/Django Commands === #
makemigrations:
	@echo "Creating new migrations..."
	python manage.py makemigrations

migrate:
	@echo "Applying database migrations..."
	python manage.py migrate

runserver:
	@echo "Starting Django development server..."
	python manage.py runserver

shell:
	@echo "Opening Django shell..."
	python manage.py shell_plus


# === Formatting and Linting --> black and ruff === #
format:
	@echo "Formatting code with Black..."
	python -m black apps config manage.py

lint:
	@echo "Running Ruff linter..."
	ruff check .

lint-fix:
	@echo "Fixing code with Ruff..."
	ruff check . --fix

# === Testing === #
#test: TODO: this is not working, fix it.
#	@echo "Running tests with pytest..."
#	pytest --ds=config.settings.test
