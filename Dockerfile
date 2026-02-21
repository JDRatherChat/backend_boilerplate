# syntax=docker/dockerfile:1

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl \
    && rm -rf /var/lib/apt/lists/*

# Install python deps
COPY requirements/ /app/requirements/
RUN pip install --no-cache-dir -U pip \
    && pip install --no-cache-dir -r /app/requirements/dev.in

# Copy project
COPY . /app/

# Create a non-root user
RUN useradd -ms /bin/bash appuser
USER appuser

EXPOSE 8000

CMD ["bash", "-lc", "python scripts/wait_for_db.py && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
