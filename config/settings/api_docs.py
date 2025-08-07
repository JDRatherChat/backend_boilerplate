from drf_spectacular.extensions import OpenApiAuthenticationExtension
from drf_spectacular.plumbing import build_bearer_security_scheme_object


class JWTScheme(OpenApiAuthenticationExtension):
    target_class = "rest_framework_simplejwt.authentication.JWTAuthentication"
    name = "JWT"

    def get_security_definition(self, auto_schema):
        return build_bearer_security_scheme_object(
            header_name="Authorization",
            bearer_format="JWT",
            schema_type="http",
            scheme="bearer",
        )


SPECTACULAR_SETTINGS = {
    "TITLE": "Project API",
    "DESCRIPTION": "API documentation for the project",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "SWAGGER_UI_SETTINGS": {
        "persistAuthorization": True,
    },
    "PREPROCESSING_HOOKS": [],
    "SERVE_PERMISSIONS": ["rest_framework.permissions.IsAuthenticated"],
    "SECURITY": [{"JWT": []}],
}
