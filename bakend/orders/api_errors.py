from rest_framework.exceptions import PermissionDenied

from .domain.policies import RoleNotAllowedError, SelfPurchaseError

_CODES = [
    (SelfPurchaseError, "self_purchase"),
    (RoleNotAllowedError, "role_not_allowed"),
]


def deny(exc: Exception):
    """Domen xatosini {"detail", "code"} ko'rinishida 403 qilib qaytaradi."""
    code = next((c for cls, c in _CODES if isinstance(exc, cls)), "forbidden")
    raise PermissionDenied({"detail": str(exc), "code": code})
