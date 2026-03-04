from django.contrib import admin
from django.urls import include, path

from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)


urlpatterns = [
    # Admin
    path("admin/", admin.site.urls),

    # API docs (OpenAPI)
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularRedocView.as_view(url_name="schema"), name="redoc"),
    path("api/swagger/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),

    path("auth/", include("apps.custom_user.urls", namespace="custom_user")),
]
