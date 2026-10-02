from rest_framework import serializers
from bouquets.serializers import BouquetCompositionSerializer
from products.serializers import ProductSerializer  # Loyihangizdagi serializer
from .models import CartItem

class CartItemSerializer(serializers.ModelSerializer):
    product_detail = ProductSerializer(source="product", read_only=True)
    bouquet_detail = BouquetCompositionSerializer(source="bouquet_composition", read_only=True)
    unit_price = serializers.SerializerMethodField()
    line_total = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = [
            "id", "product", "product_detail", "bouquet_composition", "bouquet_detail",
            "quantity", "unit_price", "line_total", "added_at",
        ]
        read_only_fields = ["id", "added_at"]

    def get_unit_price(self, obj):
        return obj.product.price if obj.product_id else obj.bouquet_composition.total_price

    def get_line_total(self, obj):
        return self.get_unit_price(obj) * obj.quantity

    def validate(self, data):
        product = data.get("product")
        composition = data.get("bouquet_composition")
        if bool(product) == bool(composition):
            raise serializers.ValidationError(
                "Aynan bittasi tanlanishi kerak: product yoki bouquet_composition."
            )
        if composition and composition.user_id != self.context["request"].user.id:
            raise serializers.ValidationError("Bu dasta sizga tegishli emas.")
        return data