from rest_framework import serializers
from .models import Shop


class ShopSerializer(serializers.ModelSerializer):
    city_name = serializers.CharField(source='city.name', read_only=True)
    # total_sold = serializers.IntegerField(read_only=True)   # annotate orqali keladi
    # product_count = serializers.IntegerField(read_only=True)  # annotate orqali keladi

    class Meta:
        model = Shop
        fields = [
            'id', 'shop_type', 'name', 'address', 'city', 'city_name',
            'latitude', 'longitude', 'is_default',
        ]
        # fields = [
        #     'id', 'shop_type', 'name', 'address', 'city', 'city_name',
        #     'latitude', 'longitude', 'is_default',
        #     'total_sold', 'product_count',
        # ]

    def validate(self, attrs):
        shop_type = attrs.get('shop_type', getattr(self.instance, 'shop_type', 'personal'))
        name = attrs.get('name', getattr(self.instance, 'name', ''))

        if shop_type == 'business' and not name:
            raise serializers.ValidationError(
                {'name': "Rasmiy do'kon uchun nom majburiy"}
            )
        return attrs