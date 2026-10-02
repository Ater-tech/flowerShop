from rest_framework import serializers
from .models import Order, OrderItem

class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = [
            "id", "product", "bouquet_composition",
            "name_snapshot", "unit_price_snapshot", "quantity",
        ]
        read_only_fields = fields

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    is_completed = serializers.BooleanField(read_only=True)

    class Meta:
        model = Order
        fields = [
            "id", "shop", "status", "total_price", "is_completed",
            "created_at", "updated_at", "items",
        ]
        read_only_fields = fields