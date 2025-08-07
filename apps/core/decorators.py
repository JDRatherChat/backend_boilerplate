from functools import wraps

from django.core.cache import cache
from django.http import HttpResponseTooManyRequests
from rest_framework import status
from rest_framework.response import Response


def rate_limit(key_prefix, limit=100, period=3600):
    def decorator(view_func):
        @wraps(view_func)
        def wrapped_view(request, *args, **kwargs):
            client_ip = request.META.get(
                "HTTP_X_FORWARDED_FOR",
                request.META.get("REMOTE_ADDR"),
            )
            cache_key = f"rate_limit:{key_prefix}:{client_ip}"

            # Get current request count
            requests = cache.get(cache_key, 0)

            if requests >= limit:
                if isinstance(request, Response):
                    return Response(
                        {"detail": "Request limit exceeded"},
                        status=status.HTTP_429_TOO_MANY_REQUESTS,
                    )
                return HttpResponseTooManyRequests()

            # Increment request count
            cache.set(cache_key, requests + 1, period)

            return view_func(request, *args, **kwargs)

        return wrapped_view

    return decorator
