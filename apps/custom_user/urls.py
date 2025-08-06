from django.urls import path

from . import views

app_name = "custom_user"

urlpatterns = [
    path("register/", views.RegisterView.as_view(), name="register"),
    path("me/", views.CurrentUserView.as_view(), name="current_user"),
    path("token/", views.ObtainJWTTokenView.as_view(), name="token_obtain_pair"),
]
