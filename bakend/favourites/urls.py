from rest_framework.routers import DefaultRouter
from .views import FavouriteViewSet

router = DefaultRouter()

router.register("favourites", FavouriteViewSet, basename="favourite")
urlpatterns = router.urls