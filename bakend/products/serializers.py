from rest_framework import serializers
from .models import ProductModel

class ProductSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ProductModel
        fields = "__all__"

    def get_image_url(self, obj):
        request = self.context.get("request")

        if request and obj.image:
            return request.build_absolute_uri(
                obj.image.url
            )
        
        return None