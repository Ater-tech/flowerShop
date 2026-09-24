# products/views_discover.py — YANGI fayl
from django.db.models import F
from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView

from products.models import ProductModel
from products.selectors import popular_products, recommended_products
from products.serializers import ProductSerializer  


class _DiscoverView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = ProductSerializer
    pagination_class = None  # 10 tadan iborat blok, sahifalash kerak emas
    filter_backends = []     # kesilgan (sliced) queryset'ga filtr qo'llab bo'lmaydi
    selector = None

    def get_limit(self) -> int:
        try:
            limit = int(self.request.query_params.get("limit", 10))
        except ValueError:
            limit = 10
        return max(1, min(limit, 20))  # klient 10000 so'rab serverni yiqitmasin

    def get_queryset(self):
        return type(self).selector(self.get_limit(), self.request.user)


class RecommendedProductsView(_DiscoverView):
    selector = staticmethod(recommended_products)


class PopularProductsView(_DiscoverView):
    selector = staticmethod(popular_products)


class SearchHitView(APIView):
    """Foydalanuvchi qidiruv natijasidan mahsulotni ochganda chaqiriladi."""
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "search_hit"

    def post(self, request, pk):
        # F() — o'qib-yozish emas, bitta atomik UPDATE: bir vaqtdagi
        # so'rovlarda ham hisob yo'qolmaydi (race condition bo'lmaydi).
        updated = Product.objects.filter(pk=pk).update(search_count=F("search_count") + 1)
        return Response(status=204 if updated else 404)