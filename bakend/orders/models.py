from django.conf import settings
from django.db import models

from bouquets.models import BouquetComposition
from products.models import ProductModel
from shop.models import Shop

from .domain.lifecycle import ARCHIVED_STATUSES, FulfillmentMethod, OrderStatus

STATUS_LABELS = {
    OrderStatus.NEW: "Yangi",
    OrderStatus.ACCEPTED: "Qabul qilindi",
    OrderStatus.COMPLETED: "Bajarildi",
    OrderStatus.REJECTED: "Rad etildi",
    OrderStatus.CANCELLED: "Bekor qilindi",
    OrderStatus.EXPIRED: "Muddati o'tdi",
}
FULFILLMENT_LABELS = {
    FulfillmentMethod.PICKUP: "Borib olish",
    FulfillmentMethod.TAXI: "Taxi orqali",
    FulfillmentMethod.SELLER_DELIVERY: "Sotuvchi yetkazadi",
    FulfillmentMethod.MEETUP: "Kelishilgan joyda",
}


class Order(models.Model):
    """Bitta Order = bitta xaridor + bitta do'kon (sotuvchi)."""

    STATUS_CHOICES = [(s.value, STATUS_LABELS[s]) for s in OrderStatus]
    FULFILLMENT_CHOICES = [(m.value, FULFILLMENT_LABELS[m]) for m in FulfillmentMethod]

    # "Bajarilganlar" bandi: frontend pastga tushirib, xira ko'rsatadi.
    COMPLETED_STATUSES = frozenset(s.value for s in ARCHIVED_STATUSES)

    buyer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="orders",
    )
    shop = models.ForeignKey(Shop, on_delete=models.PROTECT, related_name="orders")

    status = models.CharField(
        max_length=12, choices=STATUS_CHOICES, default=OrderStatus.NEW.value, db_index=True,
    )

    fulfillment_method = models.CharField(
        max_length=16, choices=FULFILLMENT_CHOICES, default=FulfillmentMethod.PICKUP.value,
    )
    # MEETUP uchun: xaridor taklif qilgan joy/izoh
    meetup_note = models.CharField(max_length=255, blank=True)
    # Gul uchun muhim: xaridorga qachon kerak
    desired_at = models.DateTimeField(null=True, blank=True)
    # NEW holatda shu vaqtgacha sotuvchi javob bermasa, EXPIRED bo'ladi (null = cheksiz)
    expires_at = models.DateTimeField(null=True, blank=True, db_index=True)

    total_price = models.DecimalField(max_digits=14, decimal_places=3, default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["shop", "status"]),
            models.Index(fields=["buyer", "status"]),
        ]

    @property
    def is_completed(self) -> bool:
        return self.status in self.COMPLETED_STATUSES

    def __str__(self):
        return f"Order #{self.pk} — {self.status}"


class OrderItem(models.Model):
    """
    product yoki bouquet_composition'dan ko'pi bilan bittasi to'ldirilgan bo'ladi.

    SET_NULL tufayli mahsulot o'chirilsa ikkalasi ham NULL bo'lishi mumkin,
    shuning uchun "aynan bitta" emas, "ikkalasi birdan emas" tekshiriladi.
    Tarix name_snapshot va unit_price_snapshot bilan saqlanadi.
    """

    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name="items")
    product = models.ForeignKey(
        ProductModel, on_delete=models.SET_NULL, null=True, blank=True, related_name="+",
    )
    bouquet_composition = models.ForeignKey(
        BouquetComposition, on_delete=models.SET_NULL, null=True, blank=True, related_name="+",
    )
    name_snapshot = models.CharField(max_length=150)
    unit_price_snapshot = models.DecimalField(max_digits=12, decimal_places=3)
    quantity = models.PositiveIntegerField(default=1)

    class Meta:
        constraints = [
            models.CheckConstraint(
                check=~(
                    models.Q(product__isnull=False)
                    & models.Q(bouquet_composition__isnull=False)
                ),
                name="orderitem_exactly_one_content_type",
            ),
        ]

    @property
    def line_total(self):
        return self.unit_price_snapshot * self.quantity
