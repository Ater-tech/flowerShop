from rest_framework import generics, permissions
from rest_framework.response import Response 

from .cart_item_quantity_serializers import CartItemQuantitySerializer
from .serializers import CartItemSerializer
from .models import CartItem

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

    def get_serializer_class(self):
        if self.request.method in ("PUT", "PATCH"):
            return CartItemQuantitySerializer
        return CartItemSerializer
    
    def get_queryset(self):
        return CartItem.objects.filter(user=self.request.user)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop("partial", False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(CartItemSerializer(instance, context=self.get_serializer_context()).data)
    