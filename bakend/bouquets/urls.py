from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import (
    AddonViewSet,
    BouquetCompositionCreateView,
    BouquetCompositionDetailView,
    FlowerVarietyViewSet,
    PackagingViewSet,
)

router = DefaultRouter()
router.register("flower-varieties", FlowerVarietyViewSet, basename="flower-varieties")
router.register("packagings", PackagingViewSet, basename="packagings")
router.register("addons", AddonViewSet, basename="addons")

urlpatterns = [
    path("compositions/", BouquetCompositionCreateView.as_view()),
    path("compositions/<int:pk>/", BouquetCompositionDetailView.as_view()),
] + router.urls