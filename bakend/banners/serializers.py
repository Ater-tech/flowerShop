from rest_framework import serializers
from .models import Banner


class BannerSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Banner
        fields = [
            "id", "title", "image", "image_url",
            "placement", "target_type", "target_id", "link_url",
            "order", "is_active", "start_date", "end_date",
            "impressions", "clicks", "created_at",
        ]
        read_only_fields = ["id", "impressions", "clicks", "created_at"]
        extra_kwargs = {"image": {"write_only": True}}

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return obj.image.url if obj.image else None

    def validate(self, attrs):
        t = attrs.get("target_type", getattr(self.instance, "target_type", "none"))
        if t in ("product", "shop") and not attrs.get(
            "target_id", getattr(self.instance, "target_id", None)
        ):
            raise serializers.ValidationError({"target_id": "Bu maydon majburiy."})
        if t == "url" and not attrs.get(
            "link_url", getattr(self.instance, "link_url", None)
        ):
            raise serializers.ValidationError({"link_url": "Bu maydon majburiy."})
        return attrs