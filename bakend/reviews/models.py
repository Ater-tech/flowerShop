from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
from products.models import ProductModel
from users.models import User
class Review(models.Model):
    product = models.ForeignKey(
        ProductModel, on_delete=models.CASCADE, related_name="reviews"
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="reviews"
    )
    
    rating = models.PositiveSmallIntegerField(
        validators = [MinValueValidator(1), MaxValueValidator(5)]
    )
    
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        # har bir mahsulotga bitta sharx mumkin
        unique_together = ("product", "user")
        ordering = ['-created_at']
        
    def __str__(self):
        return f"{self.user} -> {self.product}({self.rating})"
    
