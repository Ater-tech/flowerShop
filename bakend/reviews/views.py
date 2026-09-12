from rest_framework import viewsets, permissions
from django_filters.rest_framework import DjangoFilterBackend
from .models import Review
from .serializers import ReviewSerializer
from .permissions import IsReviewOwnerOrReadOnly


class ReviewViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsReviewOwnerOrReadOnly]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ["product"]

    def get_queryset(self):
        return Review.objects.select_related("user").order_by("-created_at")