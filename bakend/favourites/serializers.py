from rest_framework import serializers
from .models import Favourite
from products.serializers import FlowerSerializer


class FavouriteSerializer(serializers.ModelSerializer):
    flower_detail = FlowerSerializer(source="products.description", read_only=True)

    class Meta:
        model = Favourite
        fields = ["id", "flower", "flower_detail", "created_at"]
        read_only_fields = ["id", "created_at"]