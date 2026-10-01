from django.db import models
from django.conf import settings

from shop.models import Shop

class FlowerVariety(models.Model):
    shop = models.ForeignKey(
        Shop,
        on_delete=models.CASCADE,
        related_name="flower_varieties",        
    )
    
    name = models.CharField(max_length=100)
    image = models.ImageField(upload_to="images/flower_varieties/")
    unit_price = models.DecimalField(max_digits=12, decimal_places=3)
     # 0 = zaxira kuzatilmaydi (hozircha ixtiyoriy, keyin stock nazoratiga ulanadi)
    stock = models.PositiveIntegerField(default=0)

    available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["name"]
        verbose_name_plural = "Flower varieties"

    def __str__(self):
        return f"{self.name} ({self.shop_id})"


class Packaging(models.Model):
    shop = models.ForeignKey(
        Shop,
        on_delete=models.CASCADE,
        related_name="packagings",
    )
    name = models.CharField(max_length=100)
    image = models.ImageField(
        upload_to="images/packagings/",
        blank=True,
        null=True,
    )
    price = models.DecimalField(max_digits=12, decimal_places=3)
    available = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class Addon(models.Model):
    shop = models.ForeignKey(
        Shop,
        on_delete=models.CASCADE,
        related_name="addons",
    )
    name = models.CharField(max_length=100)
    image = models.ImageField(
        upload_to="images/addons/",
        blank=True,
        null=True,
    )
    price = models.DecimalField(max_digits=12, decimal_places=3)
    available = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class BouquetComposition(models.Model):
    """
    Customer yig'gan custom dasta.

    Yaratilgach narx darhol hisoblanib total_price'ga yoziladi.
    Do'kon keyin narx o'zgartirsa ham, bu dasta va unga bog'liq
    savat/buyurtma narxi o'zgarmay qoladi.
    """

    shop = models.ForeignKey(
        Shop,
        on_delete=models.PROTECT,
        related_name="bouquet_compositions",
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="bouquet_compositions",
    )

    packaging = models.ForeignKey(
        Packaging,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="+",
    )

    packaging_price_snapshot = models.DecimalField(
        max_digits=12,
        decimal_places=3,
        default=0,
    )

    total_price = models.DecimalField(
        max_digits=12,
        decimal_places=3,
        default=0,
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def recalculate_total(self, save: bool = True):
        flowers_total = sum(
            item.unit_price_snapshot * item.quantity
            for item in self.items.all()
        )

        addons_total = sum(
            link.price_snapshot
            for link in self.addon_links.all()
        )

        self.total_price = (
            flowers_total
            + self.packaging_price_snapshot
            + addons_total
        )

        if save:
            self.save(update_fields=["total_price"])

        return self.total_price

    def __str__(self):
        return f"Dasta #{self.pk} — do'kon {self.shop_id}"


class BouquetCompositionItem(models.Model):
    composition = models.ForeignKey(
        BouquetComposition,
        on_delete=models.CASCADE,
        related_name="items",
    )

    flower_variety = models.ForeignKey(
        FlowerVariety,
        on_delete=models.PROTECT,
        related_name="+",
    )

    quantity = models.PositiveIntegerField(default=1)

    unit_price_snapshot = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["composition", "flower_variety"],
                name="unique_flower_per_composition",
            ),
        ]


class BouquetCompositionAddon(models.Model):
    composition = models.ForeignKey(
        BouquetComposition,
        on_delete=models.CASCADE,
        related_name="addon_links",
    )

    addon = models.ForeignKey(
        Addon,
        on_delete=models.PROTECT,
        related_name="+",
    )

    price_snapshot = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["composition", "addon"],
                name="unique_addon_per_composition",
            ),
        ]

