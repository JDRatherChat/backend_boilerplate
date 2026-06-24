from django.apps import AppConfig


class CustomUserConfig(AppConfig):
    name = "apps.custom_user"

    def ready(self):
        import apps.custom_user.schema  # noqa: F401  registers JWTScheme with drf-spectacular
