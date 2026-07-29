from rest_framework import viewsets, permissions
from .models import Favourite
from .serializers import FavouriteSerializer


class FavouriteViewSet(viewsets.ModelViewSet):
    serializer_class = FavouriteSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ["get", "post", "delete"]

    def get_queryset(self):
        return Favourite.objects.filter(user=self.request.user).select_related("flower", "flower__seller")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
        
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
        
        favourite = Favourite.objects.filter(user=request.user, flower_id=flower_id).first()
        if favourite:
            favourite.delete()
            return Response({"is_favourited": False}, status=status.HTTP_200_OK)

        Favourite.objects.create(user=request.user, flower_id=flower_id)
        return Response({"is_favourited": True}, status=status.HTTP_201_CREATED)    