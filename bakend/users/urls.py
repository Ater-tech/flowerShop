from django.urls import path
from .views import ChangePasswordView, ProfileView

urlpatterns = [
    path("me/", ProfileView.as_view(), name="profile"),
    path("me/change-password/", ChangePasswordView.as_view(), name="change-password"),
]
