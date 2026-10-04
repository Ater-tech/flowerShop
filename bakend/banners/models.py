from django.db import models


class Banner(models.Model):
    class Placement(models.TextChoices):
        HOME_TOP = "home_top", "Home (yuqori)"
        SEARCH = "search", "Qidiruv"
        PRODUCT_DETAIL = "product_detail", "Mahsulot sahifasi"

    class TargetType(models.TextChoices):
        NONE = "none", "Yo'q"
        PRODUCT = "product", "Mahsulot"
        SHOP = "shop", "Do'kon"
        URL = "url", "Tashqi havola"

    title = models.CharField(max_length=255, blank=True)
    image = models.ImageField(upload_to="banners/")

    placement = models.CharField(
        max_length=20, choices=Placement.choices, default=Placement.HOME_TOP
    )
    target_type = models.CharField(
        max_length=10, choices=TargetType.choices, default=TargetType.NONE
    )
    target_id = models.PositiveIntegerField(blank=True, null=True)
    link_url = models.URLField(blank=True, null=True)

    order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    start_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)

    impressions = models.PositiveIntegerField(default=0)
    clicks = models.PositiveIntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["order", "-created_at"]
        indexes = [models.Index(fields=["placement", "is_active"])]

    def __str__(self):
        return self.title or f"Banner {self.pk}"