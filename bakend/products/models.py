from django.db import models
from shop.models import Shop


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
    sold_count = models.PositiveIntegerField(default=0)
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
    free_product_limit = models.PositiveIntegerField(default=1)
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