from django.urls import path
from .views import FlowerViewSet
from rest_framework.routers import DefaultRouter


router = DefaultRouter()
router.register("flowers", FlowerViewSet)

urlpatterns = router.urls