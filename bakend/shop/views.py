from django.db.models import Sum, Count
from django.db.models.functions import Coalesce
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Shop
from .serializers import ShopSerializer
from .permissions import IsShopOwnerOrReadOnly

total_sold=Coalesce(Sum('products__sold_count'), 0),

class ShopViewSet(viewsets.ModelViewSet):
    serializer_class = ShopSerializer
    permission_classes = [IsAuthenticated, IsShopOwnerOrReadOnly]

    def get_queryset(self):
        return Shop.objects.filter(seller__user=self.request.user)
        # return Shop.objects.filter(
        #     seller__user=self.request.user
        # ).annotate(
        #     total_sold=Sum('products__sold_count'),
        #     product_count=Count('products'),
        # )

    def perform_create(self, serializer):
        serializer.save(seller=self.request.user.seller_profile)

    @action(detail=True, methods=['post'])
    def set_default(self, request, pk=None):
        shop = self.get_object()
        shop.is_default = True
        shop.save()
        return Response({'status': 'default shop belgilandi'})