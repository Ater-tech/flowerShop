from django.db import models
from django.conf import settings

class Seller(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name="seller_profile")
    rating_avg = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    is_premium = models.BooleanField(default=False)  # pullik obuna
    premium_expires_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    paid_product_slots = models.PositiveIntegerField(
            default=0,
            help_text="Foydalanuvchi 5000 so'mga sotib olgan, hali ishlatilmagan qo'shimcha mahsulot slotlari"
        )
    
    def __str__(self):
        return self.shop_name
