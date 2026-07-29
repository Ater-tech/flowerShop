from django.db import models
from django.conf import settings

class Seller(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name="seller_profile")
    shop_name = models.CharField(max_length=255)
    rating_avg = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    is_premium = models.BooleanField(default=False)  # pullik obuna
    premium_expires_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.shop_name