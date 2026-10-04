import os
import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser

def avatar_upload_path(instance, filename):
    ext = os.path.splitext(filename)[1].lower()
    return f"avatars/{instance.pk}/{uuid.uuid4().hex}{ext}"


class User(AbstractUser):
    phone_number = models.CharField(max_length=20, blank=True, null=True, unique=True)
    gmail = models.CharField(max_length=40, blank=True, null=True)
    avatar = models.ImageField(
        upload_to=avatar_upload_path,
        null=True,
        blank=True,
    )
    city = models.ForeignKey(
        "city.City",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="users",
        ) 
    
    def __str__(self):
        return self.phone_number or self.username