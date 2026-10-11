from django.db.models import Sum, Count, ProtectedError
from django.db.models.functions import Coalesce
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import generics, permissions

from .models import Shop
from .serializers import ShopSerializer
from .permissions import IsShopOwnerOrReadOnly

# total_sold=Coalesce(Sum('products__sold_count'), 0),

class ShopViewSet(viewsets.ModelViewSet):
    serializer_class = ShopSerializer
    permission_classes = [IsAuthenticated, IsShopOwnerOrReadOnly]

    def get_queryset(self):
        return Shop.objects.filter(seller__user=self.request.user)        

    def perform_create(self, serializer):
        serializer.save(seller=self.request.user.seller_profile)

    @action(detail=True, methods=['post'])
    def set_default(self, request, pk=None):
        shop = self.get_object()
        shop.is_default = True
        shop.save()
        return Response({'status': 'default shop belgilandi'})
    def destroy(self, request, *args, **kwargs):
        try:
            return super().destroy(request, *args, **kwargs)
        except ProtectedError:
            return Response(
                {"detail": "Buyurtmalari bor do'konni o'chirib bo'lmaydi.", "code": "shop_has_orders"},
                status=409,
            )

class PublicShopDetailView(generics.RetrieveAPIView):
    serializer_class = ShopSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        return Shop.objects.select_related('city', 'seller', 'seller__user').annotate(
            product_count=Count('products', distinct=True),
            total_sold=Coalesce(Sum('products__sold_count'), 0),
        )

# shop/views.py uchun ikkita kichik tuzatish:

# 1) Faylning boshidagi bu qator ortiqcha (tuple yaratadi, hech narsa qilmaydi) — o'chiring:
# total_sold=Coalesce(Sum('products__sold_count'), 0),

# 2) Order.shop PROTECT bo'lgani uchun buyurtmasi bor do'konni o'chirish 500 beradi.
#    ShopViewSet ichiga qo'shing:
#
# from django.db.models import ProtectedError
#
# def destroy(self, request, *args, **kwargs):
#     try:
#         return super().destroy(request, *args, **kwargs)
#     except ProtectedError:
#         return Response(
#             {"detail": "Buyurtmalari bor do'konni o'chirib bo'lmaydi.", "code": "shop_has_orders"},
#             status=409,
#         )