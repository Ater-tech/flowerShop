from rest_framework import generics, permissions, viewsets
from shop.models import Shop
from .models import Addon, BouquetComposition, FlowerVariety, Packaging
from .serializers import (
    AddonSerializer,
    BouquetCompositionCreateSerializer,
    BouquetCompositionSerializer,
    FlowerVarietySerializer,
    PackagingSerializer,
)

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.shop.seller.user_id == request.user.id

class _ShopComponentViewSet(viewsets.ModelViewSet):
    def get_permissions(self):
        if self.request.method in permissions.SAFE_METHODS:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated(), IsOwnerOrReadOnly()]

    def get_queryset(self):
        qs = self.queryset
        shop_id = self.request.query_params.get("shop")
        if shop_id:
            qs = qs.filter(shop_id=shop_id)
        user = self.request.user
        owns_shop = (
            shop_id is not None
            and user.is_authenticated
            and Shop.objects.filter(pk=shop_id, seller__user=user).exists()
        )
        if self.request.method in permissions.SAFE_METHODS and not owns_shop:
            qs = qs.filter(available=True)
        return qs

class FlowerVarietyViewSet(_ShopComponentViewSet):
    queryset = FlowerVariety.objects.select_related("shop")
    serializer_class = FlowerVarietySerializer

class PackagingViewSet(_ShopComponentViewSet):
    queryset = Packaging.objects.select_related("shop")
    serializer_class = PackagingSerializer

class AddonViewSet(_ShopComponentViewSet):
    queryset = Addon.objects.select_related("shop")
    serializer_class = AddonSerializer

class BouquetCompositionCreateView(generics.CreateAPIView):
    serializer_class = BouquetCompositionCreateSerializer
    permission_classes = [permissions.IsAuthenticated]

class BouquetCompositionDetailView(generics.RetrieveAPIView):
    serializer_class = BouquetCompositionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return BouquetComposition.objects.filter(user=self.request.user).prefetch_related(
            "items__flower_variety", "addon_links__addon"
        )