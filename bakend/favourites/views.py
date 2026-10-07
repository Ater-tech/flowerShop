from rest_framework import viewsets, permissions, mixins, status
from rest_framework.decorators import action
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response

from products.models import ProductModel
from .models import Favourite
from .serializers import FavouriteSerializer

class FavouriteViewSet(
    mixins.ListModelMixin,
    mixins.DestroyModelMixin,
    viewsets.GenericViewSet,):
    serializer_class = FavouriteSerializer
    permission_classes = [permissions.IsAuthenticated]
    # http_method_names = ["get", "post", "delete"]

    def get_queryset(self):
        return (
        Favourite.objects
        .filter(user=self.request.user)
        .select_related(
            "flower",
            "flower__shop",
            "flower__shop__seller__user",
            "flower__shop__city",
        )
    )

    # def perform_create(self, serializer):
    #     serializer.save(user=self.request.user)
        
    @action(detail = False, methods=["post"], url_path = "toggle")
    def toggle(self, request):
        flower_id = request.data.get("flower")
        if not flower_id:
            return Response(
                {
                "detail": "flower field is required", 
            },
                status = status.HTTP_400_BAD_REQUEST,
                            )
        
        flower = get_object_or_404(ProductModel, pk=flower_id)
        favourite, created = Favourite.objects.get_or_create(
            user=request.user, flower=flower)
        if not created:
            favourite.delete()
            return Response({"is_favourited": False}, status=status.HTTP_200_OK)

        return Response({"is_favourited": True}, status=status.HTTP_201_CREATED)    