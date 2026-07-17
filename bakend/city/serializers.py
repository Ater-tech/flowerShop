from rest_framework import serializers

from .models import City, UserCityPreference


class CitySerializer(serializers.ModelSerializer):
    class Meta:
        model = City
        fields = ['id', 'name']


class UserCityPreferenceSerializer(serializers.ModelSerializer):
    city_id = serializers.PrimaryKeyRelatedField(
        source='city',
        queryset=City.objects.filter(is_active=True),
        write_only=True,
    )
    city = CitySerializer(read_only=True)

    class Meta:
        model = UserCityPreference
        fields = ['city', 'city_id']