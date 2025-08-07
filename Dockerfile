# syntax=docker/dockerfile:1
FROM python:3.11-slim as builder

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Install pip-tools to compile .in files to locked .txt with hashes
RUN python -m pip install --upgrade pip pip-tools

COPY requirements/ requirements/
# Compile prod.txt from prod.in (which should include base.in)
RUN pip-compile --resolver=backtracking --generate-hashes -o /app/prod.txt /app/requirements/prod.in
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r /app/prod.txt

FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

# Create user and app directories
RUN adduser --disabled-password --gecos "" appuser \
    && mkdir -p /app/staticfiles /app/mediafiles \
    && chown -R appuser:appuser /app

# Minimal runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Install wheels produced by the builder stage
COPY --from=builder /app/wheels /wheels
RUN pip install --no-cache /wheels/*

# Copy project source
COPY . .
USER appuser

# Default to gunicorn for production containers
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
