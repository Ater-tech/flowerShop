from django.urls import path
from .views import FlowerViewSet
from rest_framework.routers import DefaultRouter


router = DefaultRouter()
router.register(r"flowers", FlowerViewSet, basename = 'flowers')

urlpatterns = router.urls