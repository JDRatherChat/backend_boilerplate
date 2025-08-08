# Python
from functools import wraps

from django.core.cache import cache
from django.http import HttpResponseTooManyRequests, JsonResponse


def rate_limit(key_prefix: str, limit: int = 100, period: int = 3600):
    """
    Simple rate limiter using Django cache.

    - key_prefix: logical prefix to distinguish different endpoints/groups.
    - limit: maximum number of requests allowed within 'period'.
    - period: time window in seconds.
    """

    def decorator(view_func):
        @wraps(view_func)
        def wrapped_view(request, *args, **kwargs):
            client_ip = request.META.get(
                "HTTP_X_FORWARDED_FOR",
                request.META.get("REMOTE_ADDR"),
            )
            cache_key = f"rate_limit:{key_prefix}:{client_ip}"

            # Get current request count
            count = cache.get(cache_key, 0)

            if count >= limit:
                # Prefer a JSON response with 429 where possible
                try:
                    return JsonResponse(
                        {"detail": "Request limit exceeded"}, status=429
                    )
                except Exception:
                    # Fallback to plain 429 response
                    return HttpResponseTooManyRequests()

            # Increment request count and set TTL
            cache.set(cache_key, count + 1, period)

            return view_func(request, *args, **kwargs)

        return wrapped_view

    return decorator
