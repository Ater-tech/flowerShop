from rest_framework.routers import DefaultRouter
from .views import ShopViewSet
from django.urls import path
from .views import PublicShopDetailView

router = DefaultRouter()
router.register('shops', ShopViewSet, basename='shop')

urlpatterns = [
    path('shops/<int:pk>/public/', PublicShopDetailView.as_view(), name='shop-public-detail'),
] + router.urls