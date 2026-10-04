from rest_framework import serializers
from products.serializers import ProductSerializer
from .models import Favourite


class FavouriteSerializer(serializers.ModelSerializer):
    flower_detail = ProductSerializer(source="flower", read_only=True)

    class Meta:
        model = Favourite
        fields = ["id", "flower", "flower_detail", "created_at"]
        read_only_fields = ["id", "flower", "created_at"]