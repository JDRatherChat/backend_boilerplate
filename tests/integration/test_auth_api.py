# tests/integration/test_auth_api.py
import pytest
from django.urls import reverse
from rest_framework import status


@pytest.mark.integration
class TestAuthAPI:

    def test_user_registration(self, api_client):
        url = reverse("user-register")
        data = {
            "email": "newuser@example.com",
            "password": "testpass123",
            "password2": "testpass123",
        }
        response = api_client.post(url, data)
        assert response.status_code == status.HTTP_201_CREATED
        assert "email" in response.data

    def test_user_login(self, api_client, user):
        url = reverse("token_obtain_pair")
        data = {
            "email": user.email,
            "password": "testpass123",
        }
        response = api_client.post(url, data)
        assert response.status_code == status.HTTP_200_OK
        assert "access" in response.data
