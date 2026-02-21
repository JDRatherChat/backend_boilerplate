# Security baseline

This template is designed for projects that may handle sensitive data.

## Baseline

- HTTPS everywhere in production
- Strong secrets management (no secrets committed)
- Least-privilege access control patterns
- Audit logging for critical actions (project-specific)

## PII / sensitive logs

If you add structured logging, ensure that request bodies and tokens are redacted.
