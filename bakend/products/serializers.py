from rest_framework import serializers
from .models import ProductModel

class ProductSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    is_favourited = serializers.SerializerMethodField()
    seller_name = serializers.CharField(source="seller.shop_name", read_only=True)
    seller_is_premium = serializers.BooleanField(source="seller.is_premium", read_only=True)
    city_name = serializers.CharField(source="city.name", read_only=True, default=None)
    class Meta:
        model = ProductModel
        exclude = ["image"]
        read_only_fields = ["id", "updated_at", "created_at"]
        
    def get_image_url(self, obj):
        request = self.context.get("request")

        if request and obj.image:
            return request.build_absolute_uri(
                obj.image.url
            )
    
        return None
    
    def get_is_favourited(self, obj):
        if hasattr(obj, "is_fav_annotated"):
            return obj.is_fav_annotated
        
        request = self.context.get("request")
        if not request or not request.user.is_authenticated:
            return False
        return obj.favourited_by.filter(user=request.user).exists()
    