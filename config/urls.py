from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    # Admin
    path("admin/", admin.site.urls),
    # Health endpoints (liveness/readiness)
    path("health/", include("apps.core.urls")),
    # Auth and user-related endpoints
    path("api/custom_user/", include("apps.custom_user.urls")),
]
