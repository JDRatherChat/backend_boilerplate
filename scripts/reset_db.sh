#!/bin/bash
echo "🗑️ Resetting database..."
python manage.py reset_db --noinput
python manage.py migrate
python manage.py loaddata initial_data
echo "✅ Database reset complete!"

# scripts/lint.sh
#!/bin/bash
echo "🔍 Running linters..."
black .
isort .
flake8 .
mypy .
echo "✅ Linting complete!"

# scripts/create_app.sh
#!/bin/bash
if [ -z "$1" ]; then
    echo "❌ Please provide an app name"
    exit 1
fi

echo "🛠️ Creating new app: $1"
mkdir -p apps/$1
python manage.py startapp $1 apps/$1
echo "✅ App created at apps/$1"
