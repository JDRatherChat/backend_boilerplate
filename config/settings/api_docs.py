SPECTACULAR_SETTINGS = {
    "TITLE": "Project API",
    "DESCRIPTION": "API documentation for the project",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "SWAGGER_UI_SETTINGS": {
        "persistAuthorization": True,
    },
    "SERVE_PERMISSIONS": ["rest_framework.permissions.AllowAny"],
    "SECURITY": [{"JWT": []}],
}
