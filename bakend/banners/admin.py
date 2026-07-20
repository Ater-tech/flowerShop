from django.contrib import admin
from .models import Banner


@admin.register(Banner)
class BannerAdmin(admin.ModelAdmin):
    list_display = ['id', 'title', 'order', 'is_active', 'start_date', 'end_date']
    list_editable = ['order', 'is_active']
    list_filter = ['is_active']