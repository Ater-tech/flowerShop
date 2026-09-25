from rest_framework import serializers
from .models import User
from .seller import Seller

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "username",
            "password",
        ]
        extra_kwargs = {
            "password": {
                "write_only" : True,
            }
        }
    
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        Seller.objects.create(user=user)
        return user