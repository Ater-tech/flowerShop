from django.contrib import admin
from .models import Shop


@admin.register(Shop)
class ShopAdmin(admin.ModelAdmin):
    list_display = ['name', 'shop_type', 'seller', 'city', 'is_default']
    list_filter = ['shop_type', 'city', 'is_default']
    search_fields = ['name', 'address']