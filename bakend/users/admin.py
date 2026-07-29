from django.contrib import admin
from .models import  User
class UserView(admin.AdminSite):
    list_display = ["id", "name"]

admin.site.register(User, UserView)
