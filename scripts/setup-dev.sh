#!/bin/bash

# Setup development environment
echo "🔧 Setting up development environment..."

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    python -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Upgrade pip and install requirements
pip install --upgrade pip
pip install -r requirements/dev.txt

# Setup pre-commit hooks
pre-commit install

# Setup database
python manage.py migrate

# Create default .env file if it doesn't exist
if [ ! -f "environments/dev.env" ]; then
    cp environments/dev.env.example environments/dev.env
    python manage.py generate_secret_key >> environments/dev.env
fi

echo "✅ Development environment setup complete!"
