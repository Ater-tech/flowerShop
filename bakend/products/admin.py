from django.contrib import admin
from .models import ProductModel


class ViewFlowers(admin.ModelAdmin):
    list_display = (
        "name", "shop_name", "aviable", "created", "price")   

admin.site.register(ProductModel, ViewFlowers)