from rest_framework import serializers
from .models import Banner

class BannerSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Banner
        fields = [
            'id', 'title', 'image', 'image_url',
            'link_url', 'order', 'is_active',
            'start_date', 'end_date', 'created_at',
        ]
        
        read_only_fields = ["id", "created_at"]
        extra_kwargs = {'image':{'write_only':True}}
        
        
    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return obj.image.url if obj.image else None            