from rest_framework import serializers
from .models import ProductModel
from shop.models import Shop


class ProductSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    is_favourited = serializers.SerializerMethodField()

    shop_name = serializers.CharField(source="shop.name", read_only=True)
    shop_type = serializers.CharField(source="shop.shop_type", read_only=True)
    city_name = serializers.CharField(source="shop.city.name", read_only=True)
    seller_is_premium = serializers.BooleanField(source="shop.seller.is_premium", read_only=True)

    class Meta:
        model = ProductModel
        exclude = ["image"]
        read_only_fields = ["id", "updated_at", "created_at"]

    def get_image_url(self, obj):
        request = self.context.get("request")
        if request and obj.image:
            return request.build_absolute_uri(obj.image.url)
        return None

    def get_is_favourited(self, obj):
        if hasattr(obj, "is_fav_annotated"):
            return obj.is_fav_annotated

        request = self.context.get("request")
        if not request or not request.user.is_authenticated:
            return False
        return obj.favourited_by.filter(user=request.user).exists()

    def validate_shop(self, shop):
        """
        Faqat o'zining shopiga product qo'sha olishi kerak.
        """
        request = self.context.get("request")
        if shop.seller.user != request.user:
            raise serializers.ValidationError("Bu do'kon sizga tegishli emas.")
        return shop