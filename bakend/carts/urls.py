from django.urls import path
from .views import CartItemDetailView, CartItemListCreateView

urlpatterns = [
    path("items/", CartItemListCreateView.as_view()),
    path("items/<int:pk>/", CartItemDetailView.as_view()),
]