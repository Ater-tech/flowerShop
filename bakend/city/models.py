from django.conf import settings
from django.db import models


class City(models.Model):
    name = models.CharField(max_length=100, unique=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['name']
        verbose_name = 'City'
        verbose_name_plural = 'Cities'

    def __str__(self):
        return self.name


class UserCityPreference(models.Model):
    """
    User bilan City o'rtasidagi bog'lanish.
    User modelini o'zgartirmaslik uchun alohida jadval.
    """
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='city_preference',
    )
    city = models.ForeignKey(
        City,
        on_delete=models.SET_NULL,
        null=True,
        related_name='user_preferences',
    )
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'{self.user} -> {self.city}'