from django.contrib import admin
from .models import ProductModel, ProductPricingConfig, ProductPromotion


class ViewFlowers(admin.ModelAdmin):
    list_display = (
        "name", "shop", "available", "created_at", "price")
    search_fields = ("name", "shop", "created_At", "price", "available")


class ProductPricingConfigAdmin(admin.ModelAdmin):
    def has_add_permission(self, request):
        return not ProductPricingConfig.objects.exists()

    def has_delete_permission(self, request, obj=None):
        return False

# @admin.register(ProductPromotion)
class ProductPromotionAdmin(admin.ModelAdmin):
    list_display = ("product", "starts_at", "ends_at", "priority")
    list_filter = ("priority", "ends_at")
    autocomplete_fields = ("product",)
    
admin.site.register(ProductModel, ViewFlowers)
admin.site.register(ProductPricingConfig, ProductPricingConfigAdmin)
admin.site.register(ProductPromotion, ProductPromotionAdmin)