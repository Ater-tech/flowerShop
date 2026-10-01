from django.conf import settings
from django.db import models

from bouquets.models import BouquetComposition
from products.models import ProductModel
from shop.models import Shop


class Order(models.Model):
    STATUS_CHOICES = [
        ("new", "Yangi"),
        ("accepted", "Qabul qilindi"),
        ("delivering", "Yetkazilmoqda"),
        ("completed", "Bajarildi"),
        ("cancelled", "Bekor qilindi"),
    ]

    # "Bajarilganlar" bandiga tushadigan holatlar.
    # Frontend shu holatga qarab pastroqqa va xira ko'rinishga o'tkazadi.
    COMPLETED_STATUSES = {"completed", "cancelled"}

    buyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="orders",
    )

    # Savatda bir nechta do'kondan mahsulot bo'lishi mumkin.
    # Checkoutda har bir do'kon uchun alohida Order yaratiladi.
    shop = models.ForeignKey(
        Shop,
        on_delete=models.PROTECT,
        related_name="orders",
    )

    status = models.CharField(
        max_length=12,
        choices=STATUS_CHOICES,
        default="new",
        db_index=True,
    )

    total_price = models.DecimalField(
        max_digits=14,
        decimal_places=3,
        default=0,
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    @property
    def is_completed(self) -> bool:
        return self.status in self.COMPLETED_STATUSES

    def __str__(self):
        return f"Order #{self.pk} — {self.status}"


class OrderItem(models.Model):
    """
    product yoki bouquet_composition'dan aynan bittasi to'ldiriladi.

    Ikkalasi ham SET_NULL: mahsulot/dasta keyin o'chirilsa ham,
    name_snapshot va unit_price_snapshot tufayli buyurtma tarixi buzilmaydi.
    """

    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name="items",
    )

    product = models.ForeignKey(
        ProductModel,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="+",
    )

    bouquet_composition = models.ForeignKey(
        BouquetComposition,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="+",
    )

    name_snapshot = models.CharField(max_length=150)

    unit_price_snapshot = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    quantity = models.PositiveIntegerField(default=1)

    class Meta:
        constraints = [
            models.CheckConstraint(
                check=(
                    models.Q(
                        product__isnull=False,
                        bouquet_composition__isnull=True,
                    )
                    |
                    models.Q(
                        product__isnull=True,
                        bouquet_composition__isnull=False,
                    )
                ),
                name="orderitem_exactly_one_content_type",
            ),
        ]

    @property
    def line_total(self):
        return self.unit_price_snapshot * self.quantity
