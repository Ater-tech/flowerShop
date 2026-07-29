from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Seller
from .serializers import SellerSerializer
from .permissions import IsOwnerOrReadOnly


class SellerViewSet(viewsets.ModelViewSet):
    queryset = Seller.objects.all()
    serializer_class = SellerSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAuthenticated])
    def me(self, request):
        """Joriy foydalanuvchining sotuvchi profilini qaytaradi"""
        seller = Seller.objects.filter(user=request.user).first()
        if not seller:
            return Response({"detail": "Sizda sotuvchi profili yo'q."}, status=404)
        serializer = self.get_serializer(seller)
        return Response(serializer.data)