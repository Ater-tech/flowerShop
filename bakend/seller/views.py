from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Seller
from .serializers import SellerSerializer
from .permissions import IsOwnerOrReadOnly, IsProductOwnerOrReadOnly


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
    

class FlowerViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsProductOwnerOrReadOnly]
    
class UpgradeToBusinessView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        if request.data.get("confirm") is not True:
            return Response({"detail": "Tasdiqlash kerak.", "code": "confirm_required"}, status=400)
        try:
            upgrade_to_business(user=request.user)
        except Seller.DoesNotExist:
            return Response({"detail": "Sotuvchi profili yo'q.", "code": "not_a_seller"}, status=404)
        except NotPersonalSellerError as e:
            return Response({"detail": str(e), "code": "not_personal_seller"}, status=403)
        except ActiveOrdersError as e:
            return Response({"detail": str(e), "code": "active_orders"}, status=409)
        return Response({"detail": "Rasmiy do'konga o'tdingiz."})