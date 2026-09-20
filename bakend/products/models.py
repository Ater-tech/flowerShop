from django.db import models
from shop.models import Shop
from django.utils import timezone

class ProductModel(models.Model):
    name = models.CharField(max_length=50, help_text="Enter the name of the flower", default="No named")
    image = models.ImageField(upload_to="images/")
    description = models.TextField(max_length=1500)

    shop = models.ForeignKey(
        Shop,
        on_delete=models.PROTECT,
        related_name="products",
    )

    available = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    price = models.DecimalField(max_digits=12, decimal_places=3)
    old_price = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    discount_percent = models.PositiveSmallIntegerField(default=0)

    rating_avg = models.DecimalField(
        max_digits=3, decimal_places=2, default=0
    )
    review_count = models.PositiveIntegerField(default=0)
    sold_count = models.PositiveIntegerField(default=0, db_index = True)
    view_count = models.PositiveIntegerField(default=0)
    is_original = models.BooleanField(default=False)

    STATUS_CHOICES = [
        ('active', 'Faol'),
        ('sold', 'Sotildi'),   # faqat personal uchun ishlatiladi
    ]
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return self.name


class ProductPricingConfig(models.Model):
    """
    Faqat bitta qator bo'lishi kerak (singleton pattern).
    Admin panel orqali narxlar va limitlar shu yerdan o'zgartiriladi.
    """
    free_product_limit = models.PositiveIntegerField(default=100)
    price_per_extra_product = models.PositiveIntegerField(default=5000)

    def save(self, *args, **kwargs):
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def get_solo(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj

    def __str__(self):
        return "Mahsulot narxlash sozlamalari"

class ProductSaleLog(models.Model):
    product = models.ForeignKey(
        ProductModel,
        on_delete=models.CASCADE,
        related_name='sale_logs'
    )
    quantity = models.PositiveIntegerField(default=1)
    sold_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=['product', 'sold_at']),
        ]
        ordering = ['-sold_at']

    def __str__(self):
        return f"{self.product_id} — {self.quantity} dona ({self.sold_at:%Y-%m-%d})"
    
class ProductPromotion(models.Model):
    """
    Pullik reklama. Product'ga `is_promoted` maydoni qo'ymaymiz, chunki:
      1) reklama muddatli (boshlanish/tugash) — maydon o'zi tugamaydi, cron kerak bo'lardi;
      2) tarix saqlanadi (kim qachon, qancha to'lagan) — keyin Payme/Click bilan bog'lanadi;
      3) bir mahsulotga bir necha marta reklama berish mumkin.
    """
    product = models.ForeignKey(
        ProductModel, on_delete=models.CASCADE, related_name="promotions",
    )
    starts_at = models.DateTimeField(default=timezone.now)
    ends_at = models.DateTimeField()
    
    # Katta son = yuqoriroq. Keyinchalik tarif (oddiy/premium) uchun tayyor
    priority = models.PositiveSmallIntegerField(default = 0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [models.Index(
            fields=["starts_at", "ends_at",]
            )]
        
    def __str__(self):
        return f"{self.product_id}: {self.starts_at:%Y-%m-%d}->{self.ends_at::%Y-%m-%d}"