from rest_framework import serializers
from .models import Favourite
from products.serializers import ProductSerializer


class FavouriteSerializer(serializers.ModelSerializer):
    flower_detail = ProductSerializer(source="products.description", read_only=True)

    class Meta:
        model = Favourite
        fields = ["id", "flower", "flower_detail", "created_at"]
        read_only_fields = ["id", "created_at"]