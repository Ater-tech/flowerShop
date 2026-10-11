from rest_framework import serializers

from orders.domain.lifecycle import LifecycleError, SellerOptions, available_methods
from orders.domain.policies import ensure_shop_type_allowed
from seller.serializers import SellerSerializer

from .models import Shop


def _fulfillment_options(shop: Shop) -> list[str]:
    opts = SellerOptions(
        delivery=shop.allows_delivery, pickup=shop.allows_pickup, taxi=shop.allows_taxi
    )
    return [m.value for m in available_methods(opts)]


class ShopSerializer(serializers.ModelSerializer):
    city_name = serializers.CharField(source='city.name', read_only=True)
    total_sold = serializers.IntegerField(read_only=True)   # annotate orqali keladi
    product_count = serializers.IntegerField(read_only=True)  # annotate orqali keladi
    name = serializers.CharField(required=False, allow_blank=True)
    seller = SellerSerializer(read_only=True)
    fulfillment_options = serializers.SerializerMethodField()

    class Meta:
        model = Shop
        fields = [
            'id', 'shop_type', 'name', 'address', 'city', 'city_name',
            'latitude', 'longitude', 'is_default',
            'allows_delivery', 'allows_pickup', 'allows_taxi', 'fulfillment_options',
            'seller', 'total_sold', 'product_count',
        ]

    def get_fulfillment_options(self, obj):
        return _fulfillment_options(obj)

    def validate(self, attrs):
        shop_type = attrs.get('shop_type', getattr(self.instance, 'shop_type', 'personal'))
        name = attrs.get('name', getattr(self.instance, 'name', ''))

        if shop_type == 'business' and not name:
            raise serializers.ValidationError(
                {'name': "Rasmiy do'kon uchun nom majburiy"}
            )

        if self.instance is None:
            # Yangi do'kon: sotuvchining mavjud do'konlari turiga mos bo'lishi kerak
            user = self.context['request'].user
            existing = set(
                Shop.objects.filter(seller__user=user).values_list('shop_type', flat=True)
            )
            try:
                ensure_shop_type_allowed(existing_types=existing, new_type=shop_type)
            except LifecycleError as exc:
                raise serializers.ValidationError({'shop_type': str(exc)})
        elif 'shop_type' in attrs and attrs['shop_type'] != self.instance.shop_type:
            # Turni PATCH orqali o'zgartirib bo'lmaydi: tarixni tozalash va faol
            # buyurtmalarni tekshirish faqat upgrade_to_business orqali bajariladi
            raise serializers.ValidationError(
                {'shop_type': "Turni bu yerda o'zgartirib bo'lmaydi."}
            )
        return attrs


class ShopMinimalSerializer(serializers.ModelSerializer):
    city_name = serializers.CharField(source='city.name', read_only=True)
    seller = SellerSerializer(read_only=True)
    fulfillment_options = serializers.SerializerMethodField()

    class Meta:
        model = Shop
        fields = [
            'id', 'shop_type', 'name', 'address', 'city', 'city_name',
            'latitude', 'longitude', 'is_default', 'seller', 'fulfillment_options',
        ]

    def get_fulfillment_options(self, obj):
        return _fulfillment_options(obj)
# from rest_framework import serializers
# from .models import Shop
# from seller.serializers import SellerSerializer

# class ShopSerializer(serializers.ModelSerializer):
#     city_name = serializers.CharField(source='city.name', read_only=True)
#     total_sold = serializers.IntegerField(read_only=True)   # annotate orqali keladi
#     product_count = serializers.IntegerField(read_only=True)  # annotate orqali keladi
#     name = serializers.CharField(required=False, allow_blank=True)
#     seller = SellerSerializer(read_only=True)
#     class Meta:
#         model = Shop
#         fields = [
#             'id', 'shop_type', 'name', 'address', 'city', 'city_name',
#             'latitude', 'longitude', 'is_default',
#             'seller', 'total_sold', 'product_count',
#         ]
#         # fields = [
#         #     'id', 'shop_type', 'name', 'address', 'city', 'city_name',
#         #     'latitude', 'longitude', 'is_default',
#         #     'total_sold', 'product_count',
#         # ]

#     def validate(self, attrs):
#         shop_type = attrs.get('shop_type', getattr(self.instance, 'shop_type', 'personal'))
#         name = attrs.get('name', getattr(self.instance, 'name', ''))

#         if shop_type == 'business' and not name:
#             raise serializers.ValidationError(
#                 {'name': "Rasmiy do'kon uchun nom majburiy"}
#             )
#         return attrs

# class ShopMinimalSerializer(serializers.ModelSerializer):
#     city_name = serializers.CharField(source='city.name', read_only=True)
#     seller = SellerSerializer(read_only=True)

#     class Meta:
#         model = Shop
#         fields = [
#             'id', 'shop_type', 'name', 'address', 'city', 'city_name',
#             'latitude', 'longitude', 'is_default', 'seller',
#         ]