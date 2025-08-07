from django.db import connections
from django.http import HttpResponse, JsonResponse


def live(request):
    # Basic process liveness check
    return HttpResponse("OK", content_type="text/plain")


def ready(request):
    # Check database connectivity
    try:
        conn = connections["default"]
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1;")
    except Exception as exc:
        return JsonResponse({"status": "unhealthy", "error": str(exc)}, status=503)
    return JsonResponse({"status": "ok"})
