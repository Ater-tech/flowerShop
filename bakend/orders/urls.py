from django.urls import path
from .views import CheckoutView, OrderDetailView, OrderListView

urlpatterns = [
    path("", OrderListView.as_view()),
    path("checkout/", CheckoutView.as_view()),
    path("<int:pk>/", OrderDetailView.as_view()),
]