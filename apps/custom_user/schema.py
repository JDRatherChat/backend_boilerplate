from drf_spectacular.extensions import OpenApiAuthenticationExtension
from drf_spectacular.plumbing import build_bearer_security_scheme_object


class JWTScheme(OpenApiAuthenticationExtension):
    target_class = "rest_framework_simplejwt.authentication.JWTAuthentication"
    name = "JWT"

    def get_security_definition(self, auto_schema):
        return build_bearer_security_scheme_object(
            header_name="Authorization",
            token_prefix="Bearer",
            bearer_format="JWT",
        )
