from rest_framework import serializers

from products.serializers import ProductSerializer
from .models import Favourite


class FavouriteSerializer(serializers.ModelSerializer):
    flower_detail = ProductSerializer(source="flower", read_only=True)

    class Meta:
        model = Favourite
        fields = ["id", "flower", "flower_detail", "created_at"]
        read_only_fields = ["id", "flower", "created_at"]

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Bu ro'yxatdagi hamma narsa ta'rifiga ko'ra sevimli.
        # Shu bilan is_favourite maydoni annotatsiyaga bog'liq bo'lmay qoladi.
        if data.get("flower_detail") is not None:
            data["flower_detail"]["is_favourited"] = True
        return data