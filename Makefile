SHELL := /bin/bash

# Default environment
ENV ?= dev
PYTHON := .venv/Scripts/python

.PHONY: runserver makemigrations migrate shell setup install deps format lint test test-fast commit ship secret superuser smoke

# Run Django development server
runserver:
	@echo "🚀 Starting Django runserver..."
	$(PYTHON) manage.py runserver

makemigrations:
	@echo "📝 Creating new migrations..."
	$(PYTHON) manage.py makemigrations

migrate:
	@echo "📦 Running database migrations..."
	$(PYTHON) manage.py migrate

shell:
	@echo "🐚 Opening Django shell..."
	$(PYTHON) manage.py shell_plus

# Setup project (new venv)
setup:
	@echo "⚙️ Setting up project..."
	python -m venv .venv
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install pip-tools pre-commit commitizen
	make install
	pre-commit install
	@echo "✅ Setup complete! Activate with: source .venv/Scripts/activate"

# Install dependencies only
install:
	@echo "📚 Installing dependencies..."
	pip-compile requirements/base.in
	pip-compile requirements/$(ENV).in
	pip-sync requirements/$(ENV).txt
	@echo "✅ Dependencies installed."

# Generate a new Django SECRET_KEY and append it to the env file
secret:
	@if [ -z "$(envfile)" ]; then \
		echo "❌ Please specify envfile: make secret envfile=environments/.dev"; \
		exit 1; \
	fi
	@echo "🔑 Generating Django SECRET_KEY..."
	SECRET_KEY=$$($(PYTHON) -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"); \
	if grep -q '^SECRET_KEY=' $(envfile); then \
		sed -i'' -e "s/^SECRET_KEY=.*/SECRET_KEY=$$SECRET_KEY/" $(envfile); \
	else \
		echo "SECRET_KEY=$$SECRET_KEY" >> $(envfile); \
	fi
	@echo "✅ SECRET_KEY updated in $(envfile)"

# Create superuser
superuser:
	@echo "Creating superuser"
	$(PYTHON) manage.py createsuperuser

# Format code
format:
	@echo "🖌️ Formatting code..."
	$(PYTHON) -m black apps config manage.py
	$(PYTHON) -m isort apps config manage.py
	@echo "✅ Formatting complete."

# Lint code
lint:
	@echo "🔍 Linting code..."
	$(PYTHON) -m flake8
	@echo "✅ Linting complete."

# Run tests with coverage
test:
	@echo "🧪 Running tests with coverage..."
	$(PYTHON) -m pytest --cov=apps --cov-report=term-missing
	@echo "✅ Tests complete."

# Run fast tests without coverage
test-fast:
	@echo "⚡ Running fast tests..."
	$(PYTHON) -m pytest
	@echo "✅ Fast tests complete."

smoke:
	@echo "🔥 Running URL smoke tests..."
	.venv/Scripts/python -m pytest apps/tests/test_urls.py -v

# Commit with quality checks
commit:
	@if [ -z "$(m)" ]; then \
		echo "❌ Please specify a commit message: make commit m='Your message'"; \
		exit 1; \
	fi
	@echo "✨ Running checks before commit..."
	make format
	make lint
	make test-fast
	@pre-commit run --all-files || (echo "❌ Pre-commit fixed files. Please re-stage and run make commit again." && exit 1)
	@git add -A
	@git commit -m "$(m)"
	@echo "✅ Commit created with message: $(m)"

# Ship versioned release
ship:
	@echo "🏷️ Shipping release..."
	@if git describe --tags --abbrev=0 >/dev/null 2>&1; then \
		cz bump --changelog; \
	else \
		echo "⚡ No previous tag found. Creating initial tag v0.0.1..."; \
		git tag -a v0.0.1 -m "Release v0.0.1"; \
		git push origin v0.0.1; \
	fi
	VERSION=$$(cz version --project || echo "0.0.1") && \
		git push --follow-tags
	@echo "✅ Release $${VERSION} shipped!"
