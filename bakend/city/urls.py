from django.urls import path

from .views import CityListView, UserCityPreferenceView

urlpatterns = [
    path('cities/', CityListView.as_view(), name='city-list'),
    path('user/city/', UserCityPreferenceView.as_view(), name='user-city'),
]