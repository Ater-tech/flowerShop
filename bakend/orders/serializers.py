from decimal import Decimal

from django.utils import timezone
from rest_framework import serializers

from .domain.lifecycle import (
    NOTICE_TEXTS_UZ, Actor, FulfillmentMethod, OrderStatus,
    allowed_actions, can_review, notices_for, stage_for,
)
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
    role = serializers.SerializerMethodField()
    stage = serializers.SerializerMethodField()
    notices = serializers.SerializerMethodField()
    actions = serializers.SerializerMethodField()
    can_review = serializers.SerializerMethodField()
    shop_info = serializers.SerializerMethodField()
    counterparty = serializers.SerializerMethodField()

    allows_delivery = serializers.SerializerMethodField()
    delivery_price = serializers.SerializerMethodField()
    class Meta:
        model = Order
        fields = [
            "id", "shop", "status", "total_price", "is_completed",
            "fulfillment_method", "meetup_note", "desired_at", "expires_at",
            "role", "stage", "notices", "actions", "can_review",
            "shop_info", "counterparty",
            "created_at", "updated_at", "items",
            "allows_delivery", "delivery_price",
        ]
        read_only_fields = fields
    
    def get_allows_delivery(self, obj):
        shop = obj.shop
        return shop.allows_delivery

    def get_delivery_price(self, obj):
        return obj.delivery_fee
        
    def _actor(self, obj: Order) -> Actor:
        user = self.context["request"].user
        return Actor.SELLER if obj.shop.seller.user_id == user.id else Actor.BUYER

    def get_role(self, obj):
        return "selling" if self._actor(obj) == Actor.SELLER else "buying"

    def get_stage(self, obj):
        return stage_for(
            OrderStatus(obj.status), FulfillmentMethod(obj.fulfillment_method), self._actor(obj)
        )

    def get_notices(self, obj):
        if obj.status != OrderStatus.ACCEPTED.value:
            return []
        method = FulfillmentMethod(obj.fulfillment_method)
        return [
            {"code": n.value, "text": NOTICE_TEXTS_UZ[n]}
            for n in notices_for(method, self._actor(obj))
        ]

    def get_actions(self, obj):
        return [a.value for a in allowed_actions(OrderStatus(obj.status), self._actor(obj))]

    def get_shop_info(self, obj):
        shop = obj.shop
        return {
            "id": shop.id,
            "name": shop.name or shop.seller.user.get_username(),
            "address": shop.address,
            "latitude": shop.latitude,
            "longitude": shop.longitude,
        }

    def get_counterparty(self, obj):
        """Aloqa ma'lumoti faqat kelishuvdan (accepted) keyin ochiladi."""
        if obj.status != OrderStatus.ACCEPTED.value:
            return None
        other = obj.buyer if self._actor(obj) == Actor.SELLER else obj.shop.seller.user
        return {
            "name": other.get_full_name() or other.get_username(),
            "phone": getattr(other, "phone_number", None) or None,
        }

    def get_can_review(self, obj):
        return can_review(OrderStatus(obj.status), self._actor(obj))


class ShopSelectionSerializer(serializers.Serializer):
    shop = serializers.IntegerField()
    fulfillment_method = serializers.ChoiceField(choices=[m.value for m in FulfillmentMethod])
    meetup_note = serializers.CharField(max_length=255, required=False, allow_blank=True, default="")
    desired_at = serializers.DateTimeField(required=False, allow_null=True, default=None)
    delivery_address = serializers.CharField(max_length=255, required=False, 
                                             allow_blank=True, default="Noma'lum")
    delivery_fee = serializers.DecimalField(max_digits=10, decimal_places=0, required=False,
                                            allow_null=True, default=Decimal("0"))

    def validate_delivery_fee(self, value):
        return value if value is not None else Decimal("0")
    
    def validate_desired_at(self, value):
        if value is not None and value <= timezone.now():
            raise serializers.ValidationError("Vaqt kelajakda bo'lishi kerak.")
        return value

    def validate(self, attrs):
        if attrs["fulfillment_method"] == FulfillmentMethod.MEETUP.value and not attrs["meetup_note"].strip():
            raise serializers.ValidationError({"meetup_note": "Uchrashuv joyini yozing."})
        return attrs


class CheckoutSerializer(serializers.Serializer):
    orders = ShopSelectionSerializer(many=True, allow_empty=False)

    def validate_orders(self, value):
        shops = [row["shop"] for row in value]
        if len(shops) != len(set(shops)):
            raise serializers.ValidationError("Bir do'kon ikki marta kiritilgan.")
        return value
