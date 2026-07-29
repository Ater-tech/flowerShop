from django.db import models
from products.models import ProductModel
from django.conf import settings

# favourites/models.py
class Favourite(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name="favourites")
    
    flower = models.ForeignKey(
        "products.ProductModel", 
        on_delete=models.CASCADE, 
        related_name="favourited_by")
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "flower")  # bir marta like bosish
        ordering = ["-created_at"]