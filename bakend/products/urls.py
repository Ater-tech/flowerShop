from django.urls import path
from .views import FlowerInfo
urlpatterns = [
    path('', FlowerInfo, name = 'product')
]