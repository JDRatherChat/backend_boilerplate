"""Sentry configuration.

We keep Sentry *lean*:
- Only initialise when SENTRY_DSN is provided.
- Capture unhandled errors/exceptions via DjangoIntegration.
- Use LoggingIntegration to record breadcrumbs (INFO+) and send ERROR logs as events.

Sentry is excellent for error monitoring and traces; it should complement (not replace)
stdout logs.
"""

from __future__ import annotations


def init_sentry(
    *,
    dsn: str,
    environment: str,
    release: str = "",
    traces_sample_rate: float = 0.0,
    profiles_sample_rate: float = 0.0,
    send_default_pii: bool = False,
    debug: bool = False,
) -> None:
    """Initialise Sentry if a DSN is configured."""

    dsn = (dsn or "").strip()
    if not dsn:
        return

    import sentry_sdk
    from sentry_sdk.integrations.django import DjangoIntegration
    from sentry_sdk.integrations.logging import LoggingIntegration

    # Breadcrumbs for INFO+; events for ERROR+
    sentry_logging = LoggingIntegration(level=20, event_level=40)

    sentry_sdk.init(
        dsn=dsn,
        environment=environment,
        release=release or None,
        integrations=[DjangoIntegration(), sentry_logging],
        traces_sample_rate=traces_sample_rate,
        profiles_sample_rate=profiles_sample_rate,
        send_default_pii=send_default_pii,
        debug=debug,
    )
