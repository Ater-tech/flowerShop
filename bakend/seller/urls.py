from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import SellerViewSet, UpgradeToBusinessView

router = DefaultRouter()
router.register("sellers", SellerViewSet, basename="seller")

urlpatterns = [
    path("seller/upgrade-to-business/", UpgradeToBusinessView.as_view()),
    *router.urls]