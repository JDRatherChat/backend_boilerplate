from django.contrib import admin
from django.urls import include, path


urlpatterns = [
    # Admin
    path("admin/", admin.site.urls),
    path("auth/", include("apps.custom_user.urls", namespace="custom_user")),
]
