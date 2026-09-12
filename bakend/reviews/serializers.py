from rest_framework import serializers
from .models import Review

class ReviewSerializer(serializers.ModelSerializer):
    user_full_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Review
        fields = [
            "id", "product", "user", "user_full_name",
            "rating", "comment", "created_at",
        ]
        read_only_fields = ["user", "created_at"]

        def get_user_full_name(self, obj):
            return obj.user.get_full_name() or obj.user.username
        
        def create(self, validated_data):
            validated_data["user"] = self.context["request"].user
            return super().create(validated_data)