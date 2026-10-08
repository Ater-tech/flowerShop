# products/permissions.py
from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsProductOwnerOrReadOnly(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        return obj.shop.owner_id == request.user.id  # shop -> owner bog'lanishingizga moslang