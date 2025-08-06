from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

User = get_user_model()


class CustomUserTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@example.com",
            password="testpass123",
            first_name="Test",
            last_name="User",
        )
        # Store URLs dynamically so renames in urls.py don’t break tests
        self.urls = {
            "register": reverse("custom_user:register"),
            "token": reverse("custom_user:token_obtain_pair"),
            "me": reverse("custom_user:current_user"),
        }

    def authenticate(self):
        """Helper: get JWT token for test user and attach to client."""
        response = self.client.post(
            self.urls["token"],
            {"email": "test@example.com", "password": "testpass123"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        token = response.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_register_user(self):
        data = {
            "email": "newuser@example.com",
            "password": "newpass123",
            "first_name": "New",
            "last_name": "User",
        }
        response = self.client.post(self.urls["register"], data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn("id", response.data)
        self.assertIn("access", response.data)

    def test_obtain_jwt_token(self):
        response = self.client.post(
            self.urls["token"],
            {"email": "test@example.com", "password": "testpass123"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)

    def test_get_current_user(self):
        self.authenticate()
        response = self.client.get(self.urls["me"])
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["email"], "test@example.com")
