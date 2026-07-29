from rest_framework import serializers
from .models import Seller


class SellerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Seller
        fields = [
            "id", "shop_name", "rating_avg",
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