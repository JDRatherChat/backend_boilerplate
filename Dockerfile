# syntax=docker/dockerfile:1
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1 \
    UV_NO_CACHE=1

WORKDIR /app

RUN pip install uv --no-cache-dir

# Install only production deps (no dev group)
COPY pyproject.toml uv.lock ./
RUN uv sync --no-dev --frozen

COPY . /app/

RUN useradd -ms /bin/bash appuser
USER appuser

EXPOSE 8000
CMD ["bash", "-lc", "scripts/run_web.sh"]
