from rest_framework import serializers
from .models import User
from seller.models import Seller
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password


User = get_user_model()

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


class ProfileSerializer(serializers.ModelSerializer):
    city_name = serializers.CharField(source="city.name", read_only=True, default=None)
    # is_seller = serializers.SerializerMethodField() 
    # har bir user seller bola oladi v abu doim True
    username = serializers.CharField()
    class Meta:
        model = User
        fields = [
            "id",
            "first_name",
            "last_name",
            "phone_number",
            "avatar",
            "city",
            "city_name",
            # "is_seller",
            "date_joined",
        ]
        # phone_number o'zgartirilmaydi (login identifikatori, OTP kerak bo'lardi)
        read_only_fields = ["id", "phone_number", "date_joined", "username"]

    def get_is_seller(self, obj):
        # Seller -> User OneToOne, related_name="seller" deb faraz qilindi
        return hasattr(obj, "seller")

    def validate_avatar(self, value):
        if value and value.size > 5 * 1024 * 1024:
            raise serializers.ValidationError("Rasm hajmi 5 MB dan oshmasligi kerak.")
        return value

    def update(self, instance, validated_data):
        # Yangi avatar kelsa, eskisini diskdan o'chiramiz
        new_avatar = validated_data.get("avatar")
        if new_avatar and instance.avatar:
            instance.avatar.delete(save=False)
        return super().update(instance, validated_data)


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)

    def validate_old_password(self, value):
        user = self.context["request"].user
        if not user.check_password(value):
            raise serializers.ValidationError("Eski parol noto'g'ri.")
        return value

    def validate_new_password(self, value):
        validate_password(value, self.context["request"].user)
        return value

    def validate(self, attrs):
        if attrs["old_password"] == attrs["new_password"]:
            raise serializers.ValidationError(
                {"new_password": "Yangi parol eskisidan farq qilishi kerak."}
            )
        return attrs

    def save(self, **kwargs):
        user = self.context["request"].user
        user.set_password(self.validated_data["new_password"])
        user.save(update_fields=["password"])
        return user