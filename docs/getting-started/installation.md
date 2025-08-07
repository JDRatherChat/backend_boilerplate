# Installation Guide

## Prerequisites

- Python 3.11+
- PostgreSQL 15+ (optional for development)
- Docker (optional)

## Local Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/project.git
   cd project
   ```

2. Create a virtual environment:
   ```bash
   make setup
   ```

3. Configure environment variables:
   ```bash
   cp environments/dev.env.example environments/dev.env
   make secret envfile=environments/dev.env
   ```

4. Run migrations:
   ```bash
   make migrate
   ```

5. Start the development server:
   ```bash
   make runserver
   ```

## Docker Setup

1. Build and start services:
   ```bash
   docker-compose up -d --build
   ```

2. Run migrations:
   ```bash
   docker-compose exec web python manage.py migrate
   ```
