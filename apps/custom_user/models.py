from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin,
)
from django.db import models
from django.utils import timezone


class CustomUserManager(BaseUserManager):
    """Manager for CustomUser with email as unique identifier."""

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractBaseUser, PermissionsMixin):
    """
    Custom User model using email instead of username.

    How to extend:
        - Add new fields (e.g., phone_number, profile_picture) directly as model fields.
        - Add related models for more complex profiles (e.g., UserProfile with OneToOne relation).
        - Update your serializers and forms/admin to include the new fields.
        - Run `python manage.py makemigrations` and `python manage.py migrate`.

    Example:
        phone_number = models.CharField(max_length=15, blank=True)
    """

    email = models.EmailField(
        unique=True,
        help_text="Required. Enter a valid email address.",
        verbose_name="email address",
        db_index=True,
    )
    first_name = models.CharField("first name", max_length=50, blank=True)
    last_name = models.CharField("last name", max_length=50, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = CustomUserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []  # No username field

    def __str__(self):
        return self.email

    class Meta:
        verbose_name = "user"
        verbose_name_plural = "users"
