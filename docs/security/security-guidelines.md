# Security Guidelines

Follow these recommendations when deploying to production.

## Configuration

- `DEBUG=False`
- Set a strong `SECRET_KEY`
- Define `ALLOWED_HOSTS`
- Enforce HTTPS (proxy/load balancer) and enable HSTS
- Configure CSRF and session cookie security flags

## Dependencies

- Pin dependencies via compiled requirements (.txt with hashes)
- Regularly update and audit dependencies

## Data and Access

- Use least-privilege DB credentials
- Rotate secrets regularly
- Backups are encrypted and tested

## Logging and Monitoring

- Configure structured logs and log rotation
- Enable error reporting (e.g., Sentry)
- Avoid logging sensitive data

## Network and Services

- Restrict inbound traffic
- Use managed database and cache services where possible
- Set up liveness/readiness probes for containers

## Process

- Review changes via pull requests
- Run CI for tests and linters on every change
- Document operational runbooks
