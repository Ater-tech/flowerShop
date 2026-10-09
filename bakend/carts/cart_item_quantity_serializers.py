from bouquets import serializers
from rest_framework import serializers

from carts.models import CartItem

class CartItemQuantitySerializer(serializers.ModelSerializer):
    quantity = serializers.IntegerField(min_value=1)

    class Meta:
        model = CartItem
        fields = ["quantity"]