from decimal import Decimal
from django.db import transaction
from rest_framework import serializers
from shop.models import Shop
from .models import (
    Addon,
    BouquetComposition,
    BouquetCompositionAddon,
    BouquetCompositionItem,
    FlowerVariety,
    Packaging,
)

class ShopOwnedSerializerMixin:
    """FlowerVariety/Packaging/Addon uchun umumiy tekshiruv: faqat o'z do'koniga yoza oladi."""
    def validate_shop(self, shop):
        request = self.context["request"]
        if shop.seller.user_id != request.user.id:
            raise serializers.ValidationError("Bu do'kon sizga tegishli emas.")
        return shop

class FlowerVarietySerializer(ShopOwnedSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = FlowerVariety
        fields = ["id", "shop", "name", "image", "unit_price", "stock", "available"]
        read_only_fields = ["id"]

class PackagingSerializer(ShopOwnedSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = Packaging
        fields = ["id", "shop", "name", "image", "price", "available"]
        read_only_fields = ["id"]

class AddonSerializer(ShopOwnedSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = Addon
        fields = ["id", "shop", "name", "image", "price", "available"]
        read_only_fields = ["id"]

# ─── O'qish uchun (nested, read-only) ───
class BouquetCompositionItemSerializer(serializers.ModelSerializer):
    flower_variety_name = serializers.CharField(source="flower_variety.name", read_only=True)

    class Meta:
        model = BouquetCompositionItem
        fields = ["id", "flower_variety", "flower_variety_name", "quantity", "unit_price_snapshot"]
        read_only_fields = fields

class BouquetCompositionAddonSerializer(serializers.ModelSerializer):
    addon_name = serializers.CharField(source="addon.name", read_only=True)

    class Meta:
        model = BouquetCompositionAddon
        fields = ["id", "addon", "addon_name", "price_snapshot"]
        read_only_fields = fields

class BouquetCompositionSerializer(serializers.ModelSerializer):
    items = BouquetCompositionItemSerializer(many=True, read_only=True)
    addon_links = BouquetCompositionAddonSerializer(many=True, read_only=True)

    class Meta:
        model = BouquetComposition
        fields = [
            "id", "shop", "packaging", "packaging_price_snapshot",
            "total_price", "created_at", "items", "addon_links",
        ]
        read_only_fields = fields

# ─── Yozish uchun (konstruktordan yaratish) ───
class BouquetItemInputSerializer(serializers.Serializer):
    flower_variety = serializers.PrimaryKeyRelatedField(queryset=FlowerVariety.objects.all())
    quantity = serializers.IntegerField(min_value=1)

class BouquetCompositionCreateSerializer(serializers.Serializer):
    shop = serializers.PrimaryKeyRelatedField(queryset=Shop.objects.all())
    packaging = serializers.PrimaryKeyRelatedField(
        queryset=Packaging.objects.all(), required=False, allow_null=True
    )
    items = BouquetItemInputSerializer(many=True)
    addons = serializers.PrimaryKeyRelatedField(
        queryset=Addon.objects.all(), many=True, required=False, default=list
    )

    def validate(self, data):
        shop = data["shop"]
        if not data["items"]:
            raise serializers.ValidationError("Kamida bitta gul tanlanishi kerak.")
        for item in data["items"]:
            fv = item["flower_variety"]
            if fv.shop_id != shop.id or not fv.available:
                raise serializers.ValidationError(
                    f"'{fv.name}' shu do'konga tegishli emas yoki mavjud emas."
                )
        packaging = data.get("packaging")
        if packaging and (packaging.shop_id != shop.id or not packaging.available):
            raise serializers.ValidationError("Tanlangan o'rash shu do'konga tegishli emas.")
        for addon in data.get("addons", []):
            if addon.shop_id != shop.id or not addon.available:
                raise serializers.ValidationError(
                    f"'{addon.name}' shu do'konga tegishli emas yoki mavjud emas."
                )
        return data

    @transaction.atomic
    def create(self, validated_data):
        user = self.context["request"].user
        shop = validated_data["shop"]
        packaging = validated_data.get("packaging")

        composition = BouquetComposition.objects.create(
            shop=shop,
            user=user,
            packaging=packaging,
            packaging_price_snapshot=packaging.price if packaging else Decimal("0"),
        )
        BouquetCompositionItem.objects.bulk_create(
            [
                BouquetCompositionItem(
                    composition=composition,
                    flower_variety=item["flower_variety"],
                    quantity=item["quantity"],
                    unit_price_snapshot=item["flower_variety"].unit_price,
                )
                for item in validated_data["items"]
            ]
        )
        BouquetCompositionAddon.objects.bulk_create(
            [
                BouquetCompositionAddon(composition=composition, addon=addon, price_snapshot=addon.price)
                for addon in validated_data.get("addons", [])
            ]
        )
        composition.recalculate_total()
        return composition

    def to_representation(self, instance):
        return BouquetCompositionSerializer(instance, context=self.context).data