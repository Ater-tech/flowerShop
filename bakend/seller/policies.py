"""Sof biznes qoidalar (Django'ga bog'liq emas)."""
from enum import Enum

from .lifecycle import LifecycleError

SHOP_TYPE_BUSINESS = "business"   # Shop.shop_type qiymati ("Rasmiy do'kon")


class SelfPurchaseError(LifecycleError):
    pass


class RoleNotAllowedError(LifecycleError):
    pass


class UpgradeNotAllowedError(LifecycleError):
    pass


class NotPersonalSellerError(UpgradeNotAllowedError):
    pass


class ActiveOrdersError(UpgradeNotAllowedError):
    pass


class ShopTypeMismatchError(LifecycleError):
    pass


class AccountKind(str, Enum):
    INDIVIDUAL = "individual"   # shaxsiy do'konlar yoki umuman do'koni yo'q
    BUSINESS = "business"       # kamida bitta rasmiy do'koni bor


def account_kind(shop_types: set[str]) -> AccountKind:
    """Foydalanuvchining do'konlari turlaridan hisob turini aniqlaydi."""
    return AccountKind.BUSINESS if SHOP_TYPE_BUSINESS in shop_types else AccountKind.INDIVIDUAL


def can_buy(kind: AccountKind) -> bool:
    return kind == AccountKind.INDIVIDUAL


def ensure_can_buy(kind: AccountKind) -> None:
    if not can_buy(kind):
        raise RoleNotAllowedError("Rasmiy do'kon hisobi xarid qila olmaydi.")


def available_tabs(shop_types: set[str]) -> list[str]:
    """Buyurtmalar bo'limida qaysi oynalar ko'rinadi."""
    tabs: list[str] = []
    if can_buy(account_kind(shop_types)):
        tabs.append("buying")
    if shop_types:               # kamida bitta do'koni bor
        tabs.append("selling")
    return tabs


def ensure_not_own_shop(*, buyer_id: int, shop_owner_id: int) -> None:
    """Hech kim o'z do'konining mahsulotini zakas qila olmaydi."""
    if buyer_id == shop_owner_id:
        raise SelfPurchaseError("O'zingizning mahsulotingizni zakas qila olmaysiz.")


def ensure_can_upgrade_to_business(*, shop_types: set[str], has_active_orders: bool) -> None:
    """Faqat shaxsiy sotuvchi o'ta oladi, va faol buyurtmalari bo'lmasligi shart."""
    if "personal" not in shop_types or SHOP_TYPE_BUSINESS in shop_types:
        raise NotPersonalSellerError("Faqat shaxsiy sotuvchi rasmiy do'konga o'ta oladi.")
    if has_active_orders:
        raise ActiveOrdersError(
            "Faol buyurtmalaringiz bor. Avval ularni yakunlang yoki bekor qiling."
        )


def ensure_shop_type_allowed(*, existing_types: set[str], new_type: str) -> None:
    """Bir sotuvchida faqat bitta tur bo'ladi. Shaxsiy → rasmiy faqat o'tish amali orqali."""
    if existing_types and existing_types != {new_type}:
        raise ShopTypeMismatchError(
            "Bir sotuvchida shaxsiy va rasmiy do'kon aralash bo'la olmaydi. "
            "Rasmiy do'konga o'tish uchun alohida o'tish amalidan foydalaning."
        )