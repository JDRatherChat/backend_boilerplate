from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import UserRegistrationSerializer, UserSerializer

User = get_user_model()


class CurrentUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)


class RegisterView(generics.CreateAPIView):
    """Register a new user with email and password."""

    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]
    queryset = User.objects.all()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)

        user_data = UserSerializer(user).data
        user_data.update(
            {
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            }
        )

        return Response(user_data, status=status.HTTP_201_CREATED)
