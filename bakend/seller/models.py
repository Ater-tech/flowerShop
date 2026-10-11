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
    
    # --- seller/models.py -> Seller modeliga qo'shing:
    history_cleared_at = models.DateTimeField(null=True, blank=True)  # shundan oldingi buyurtmalar ko'rinmaydi
    paid_product_slots = models.PositiveIntegerField(
            default=100,
            help_text="Foydalanuvchi 5000 so'mga sotib olgan, hali ishlatilmagan qo'shimcha mahsulot slotlari"
        )
    
    def __str__(self):
        return self.user.get_username()


# --- shop/models.py -> Shop modeliga qo'shing (bir sotuvchida turlar aralashmasin):
def clean(self):
    super().clean()
    mixed = (
        Shop.objects.filter(seller=self.seller)
        .exclude(pk=self.pk)
        .exclude(shop_type=self.shop_type)
    )
    if mixed.exists():
        raise ValidationError("Bir sotuvchida shaxsiy va rasmiy do'kon aralash bo'la olmaydi.")
# va save() ning boshida:  self.clean()

# --- Bazada aralash sotuvchilar bormi, tekshirish (shell):
# from django.db.models import Count
# Shop.objects.values("seller").annotate(n=Count("shop_type", distinct=True)).filter(n__gt=1)