# tests/factories/user_factory.py
import factory
from django.contrib.auth import get_user_model
from faker import Faker

fake = Faker()


class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = get_user_model()

    email = factory.LazyFunction(lambda: fake.email())
    password = factory.PostGenerationMethodCall("set_password", "testpass123")
    is_active = True
