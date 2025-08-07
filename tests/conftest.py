# tests/conftest.py
import pytest
from rest_framework.test import APIClient

from tests.factories.user_factory import UserFactory


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user():
    return UserFactory()


@pytest.fixture
def authenticated_client(api_client, user):
    api_client.force_authenticate(user=user)
    return api_client
