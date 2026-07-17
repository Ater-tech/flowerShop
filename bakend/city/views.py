from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import City, UserCityPreference
from .serializers import CitySerializer, UserCityPreferenceSerializer


class CityListView(generics.ListAPIView):
    """GET /api/cities/  -- barcha faol shaharlar ro'yxati"""
    queryset = City.objects.filter(is_active=True)
    serializer_class = CitySerializer
    permission_classes = [permissions.IsAuthenticated]


class UserCityPreferenceView(APIView):
    """
    GET  /api/user/city/  -- foydalanuvchining tanlagan shahri
    POST /api/user/city/  -- shaharni saqlash/yangilash
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        preference = UserCityPreference.objects.filter(
            user=request.user
        ).first()
        if not preference:
            return Response({'city': None})
        return Response(UserCityPreferenceSerializer(preference).data)

    def post(self, request):
        preference, _ = UserCityPreference.objects.get_or_create(
            user=request.user
        )
        serializer = UserCityPreferenceSerializer(
            preference, data=request.data, partial=True
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)