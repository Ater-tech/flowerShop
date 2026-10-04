from django.db.models import F, Q
from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Banner
from .serializers import BannerSerializer


class BannerViewSet(viewsets.ModelViewSet):
    serializer_class = BannerSerializer

    def get_permissions(self):
        if self.action in ["list", "retrieve", "click"]:
            return [permissions.AllowAny()]
        return [permissions.IsAdminUser()]

    def get_queryset(self):
        qs = Banner.objects.all()
        user = self.request.user
        is_admin = bool(user and user.is_staff)

        if not is_admin:
            now = timezone.now()
            qs = (
                qs.filter(is_active=True)
                .filter(Q(start_date__isnull=True) | Q(start_date__lte=now))
                .filter(Q(end_date__isnull=True) | Q(end_date__gte=now))
            )

        placement = self.request.query_params.get("placement")
        if placement and self.action == "list":
            qs = qs.filter(placement=placement)
        return qs

    @action(detail=True, methods=["post"], url_path="click")
    def click(self, request, pk=None):
        banner = self.get_object()
        Banner.objects.filter(pk=banner.pk).update(clicks=F("clicks") + 1)
        return Response(status=status.HTTP_204_NO_CONTENT)