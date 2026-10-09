from rest_framework import generics, permissions

from carts.cart_item_quantity_serializers import CartItemQuantitySerializer
from .models import CartItem
from .serializers import CartItemSerializer

class CartItemListCreateView(generics.ListCreateAPIView):
    serializer_class = CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return CartItem.objects.filter(user=self.request.user).select_related(
            "product", "bouquet_composition"
        )

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class CartItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return CartItem.objects.filter(user=self.request.user)

class CartItemViewSet(...):
    def get_serializer_class(self):
        if self.action in ("update", "partial_update"):
            return CartItemQuantitySerializer
        return CartItemSerializer