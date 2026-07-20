from django.db.models import Q
from django.utils import timezone
from rest_framework import viewsets, permissions
from .models import Banner
from .serializers import BannerSerializer

class BannerViewSet(viewsets.ModelViewSet):
    serializer_class = BannerSerializer
    queryset = Banner.objects.all()
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return (permissions.IsAdminUser())
    
    def get_queryset(self):
        qs = Banner.objects.all()
        is_admin = bool(self.request.user and self.request.user.is_staff)
        
        if self.action == 'list' and not is_admin:
            now = timezone.now()
            qs = qs.filter(is_active=True).filter(
                Q(start_date__isnull=True) | Q(start_date__lte=now)
            ).filter(
                Q(end_date__isnull=True) | Q(end_date__gte=now)
            )
        return qs     