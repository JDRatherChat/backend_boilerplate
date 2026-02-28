# syntax=docker/dockerfile:1

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps (keep minimal; add others only when needed)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install python deps (use pinned dev.txt for reproducible builds)
COPY requirements/ /app/requirements/
RUN pip install --no-cache-dir -U pip \
    && pip install --no-cache-dir -r /app/requirements/dev.txt

# Copy project
COPY . /app/

# Create a non-root user
RUN useradd -ms /bin/bash appuser
USER appuser

EXPOSE 8000

# Keep container startup logic in scripts (easier to read/change than long compose commands)
CMD ["bash", "-lc", "scripts/run_web.sh"]