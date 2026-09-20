from django.urls import path
from .views import FlowerViewSet
from rest_framework.routers import DefaultRouter
from .views_discover import PopularProductsView, RecommendedProductsView, SearchHitView

discover_urlpatterns = [
    path("product/discover/recommended", RecommendedProductsView.as_view()),
    path("product/discover/popular", PopularProductsView.as_view()),
    path("product/<int:pk>/search-hit", SearchHitView.as_view()),
]



router = DefaultRouter()
router.register(r"flowers", FlowerViewSet, basename = 'flowers')

urlpatterns = discover_urlpatterns + router.urls