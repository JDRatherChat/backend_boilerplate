# tests/unit/test_user_model.py
import pytest
from django.contrib.auth import get_user_model


@pytest.mark.unit
class TestUserModel:

    def test_create_user(self):
        User = get_user_model()
        user = User.objects.create_user(
            email="test@example.com",
            password="testpass123",
        )
        assert user.email == "test@example.com"
        assert user.is_active
        assert not user.is_staff
        assert not user.is_superuser

    def test_create_superuser(self):
        User = get_user_model()
        admin_user = User.objects.create_superuser(
            email="admin@example.com",
            password="testpass123",
        )
        assert admin_user.email == "admin@example.com"
        assert admin_user.is_active
        assert admin_user.is_staff
        assert admin_user.is_superuser
