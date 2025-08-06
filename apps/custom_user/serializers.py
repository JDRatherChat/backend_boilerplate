from rest_framework import serializers

from .models import CustomUser


class UserSerializer(serializers.ModelSerializer):
    """
    Default serializer for the CustomUser model.

    Purpose:
        - Exposes the user model fields for read-only or general display.
        - Does not handle password creation or updates.

    How to extend:
        - Add new fields if you extend the CustomUser model.
        - For sensitive fields like passwords, use a separate serializer.

    Example:
        fields = ["id", "email", "first_name", "last_name", "date_joined", "phone_number"]
    """

    class Meta:
        model = CustomUser
        fields = ["id", "email", "first_name", "last_name", "date_joined"]
        read_only_fields = ["id", "date_joined"]


class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for registering a new user with email + password.

    Purpose:
        - Handles user creation securely using the set_password method.
        - Includes basic fields for initial signup.

    Notes:
        - Password is write-only for security.
        - Extend fields if you add additional required profile data.
    """

    password = serializers.CharField(
        write_only=True,
        required=True,
        style={"input_type": "password"},
        help_text="Password for the account (not stored in plain text).",
    )

    class Meta:
        model = CustomUser
        fields = ["id", "email", "first_name", "last_name", "password", "date_joined"]
        read_only_fields = ["id", "date_joined"]

    def create(self, validated_data):
        """
        Create a new user with hashed password.

        Args:
            validated_data (dict): Data from the request, including password.

        Returns:
            CustomUser: The newly created user instance.
        """
        password = validated_data.pop("password")
        user = CustomUser.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user
