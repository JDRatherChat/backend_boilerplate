"""
Root URL configuration for the project.
"""

from django.conf import settings
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("auth/", include("apps.custom_user.urls", namespace="custom_user")),
    # Example for your apps:
    # path('dashboard/', include('apps.dashboard.urls')),
]

if settings.DEBUG:
    import debug_toolbar

    urlpatterns += [
        path("__debug__/", include(debug_toolbar.urls)),
    ]
