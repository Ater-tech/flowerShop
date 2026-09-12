from rest_framework import serializers
from .models import Seller


class SellerSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    phone_number = serializers.SerializerMethodField()
    class Meta:
        model = Seller
        fields = [
            "id", "rating_avg",
            "is_premium", "premium_expires_at", "created_at",
        ]
        read_only_fields = [
            "id", "rating_avg", "is_premium", "premium_expires_at", "created_at",
        ]

    def validate(self, attrs):
        request = self.context.get("request")
        # faqat create paytida tekshiramiz (update paytida instance mavjud)
        if request and request.method == "POST":
            if Seller.objects.filter(user=request.user).exists():
                raise serializers.ValidationError(
                    "Siz allaqachon sotuvchi profiliga egasiz."
                )
        return attrs
    
    def get_full_name(self, obj):
        return obj.user.get_full_name() or obj.user.username

    def get_phone_number(self, obj):
        return getattr(obj.user, "phone_number", None)