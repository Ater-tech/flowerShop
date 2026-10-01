from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models

from bouquets.models import BouquetComposition
from products.models import ProductModel


class CartItem(models.Model):
    """
    Savat qatori — foydalanuvchiga bog'liq.

    Ikki turdagi tarkibni qamrab oladi:
    - tayyor mahsulot (product)
    - o'zi yasagan dasta (bouquet_composition)

    Aynan bittasi to'ldirilishi shart.

    Narx bu yerda saqlanmaydi:
    savat "jonli" holat, checkoutda Order/OrderItem yaratilganda
    joriy narx bilan qayta hisoblanadi va o'sha yerda snapshot qilinadi.
    """

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="cart_items",
    )

    product = models.ForeignKey(
        ProductModel,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="+",
    )

    # OneToOne: bitta custom dasta bitta savat qatoriga tegishli.
    bouquet_composition = models.OneToOneField(
        BouquetComposition,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="cart_item",
    )

    quantity = models.PositiveIntegerField(default=1)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-added_at"]

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
                name="cartitem_exactly_one_content_type",
            ),
            models.UniqueConstraint(
                fields=["user", "product"],
                name="unique_product_per_user_cart",
            ),
        ]

    def clean(self):
        if bool(self.product_id) == bool(self.bouquet_composition_id):
            raise ValidationError(
                "Aynan bittasi to'ldirilishi kerak: "
                "product yoki bouquet_composition."
            )
