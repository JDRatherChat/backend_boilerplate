from django.urls import path

from . import health

urlpatterns = [
    path("live/", health.live, name="health-live"),
    path("ready/", health.ready, name="health-ready"),
]
