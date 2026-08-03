from django.contrib import admin
from .models import ProductModel, ProductPricingConfig


class ViewFlowers(admin.ModelAdmin):
    list_display = (
        "name", "seller", "available", "created_at", "price")   

class ProductPricingConfigAdmin(admin.ModelAdmin):
    def has_add_permission(self, request):
        return not ProductPricingConfig.objects.exists()

    def has_delete_permission(self, request, obj = None):
        return False

admin.site.register(ProductModel, ViewFlowers)
