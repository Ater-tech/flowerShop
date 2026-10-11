"""Buyurtma hayot sikli. Sof Python: Django, DRF yoki DB ga bog'liq emas.

Bitta Order = bitta xaridor + bitta sotuvchi. Xaridor va sotuvchi
bir xil holatlar mashinasini ko'radi, faqat nomlari (stage) farq qiladi.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


# ----------------------------------------------------------------- enumlar
class OrderStatus(str, Enum):
    NEW = "new"                # xaridor so'rov yubordi
    ACCEPTED = "accepted"     # sotuvchi qabul qildi (kelishilgan, jarayonda)
    COMPLETED = "completed"   # yakunlandi -> arxiv
    REJECTED = "rejected"     # sotuvchi rad etdi -> arxiv
    CANCELLED = "cancelled"   # bekor qilindi -> arxiv
    EXPIRED = "expired"       # sotuvchi javob bermadi -> arxiv


ACTIVE_STATUSES = frozenset({OrderStatus.NEW, OrderStatus.ACCEPTED})
ARCHIVED_STATUSES = frozenset(set(OrderStatus) - ACTIVE_STATUSES)


class FulfillmentMethod(str, Enum):
    PICKUP = "pickup"                   # xaridor o'zi borib oladi
    TAXI = "taxi"                       # xaridor chaqirgan taxi orqali
    SELLER_DELIVERY = "seller_delivery" # sotuvchi o'zi yetkazadi
    MEETUP = "meetup"                   # kelishilgan joyda ko'rishish


class Actor(str, Enum):
    BUYER = "buyer"
    SELLER = "seller"
    SYSTEM = "system"   # masalan: muddati o'tgan so'rovlarni yopuvchi job


class Action(str, Enum):
    ACCEPT = "accept"
    REJECT = "reject"
    CANCEL = "cancel"
    COMPLETE = "complete"
    EXPIRE = "expire"


# ------------------------------------------------------------------ xatolar
class LifecycleError(Exception):
    pass


class InvalidTransition(LifecycleError):
    pass


class ActionNotAllowed(LifecycleError):
    pass


class MethodNotAvailable(LifecycleError):
    pass


# ------------------------------------------------- holatlar mashinasi (jadval)
_B, _S, _SYS = Actor.BUYER, Actor.SELLER, Actor.SYSTEM

_TRANSITIONS: dict[tuple[OrderStatus, Action], tuple[OrderStatus, frozenset[Actor]]] = {
    (OrderStatus.NEW, Action.ACCEPT):   (OrderStatus.ACCEPTED,  frozenset({_S})),
    (OrderStatus.NEW, Action.REJECT):   (OrderStatus.REJECTED,  frozenset({_S})),
    (OrderStatus.NEW, Action.CANCEL):   (OrderStatus.CANCELLED, frozenset({_B})),
    (OrderStatus.NEW, Action.EXPIRE):   (OrderStatus.EXPIRED,   frozenset({_SYS})),
    (OrderStatus.ACCEPTED,  Action.COMPLETE): (OrderStatus.COMPLETED, frozenset({_B, _S})),
    (OrderStatus.ACCEPTED,  Action.CANCEL):   (OrderStatus.CANCELLED, frozenset({_B, _S})),
}


def transition(status: OrderStatus, action: Action, actor: Actor) -> OrderStatus:
    rule = _TRANSITIONS.get((status, action))
    if rule is None:
        raise InvalidTransition(f"'{status.value}' holatida '{action.value}' mumkin emas.")
    new_status, actors = rule
    if actor not in actors:
        raise ActionNotAllowed(f"'{actor.value}' '{action.value}' amalini bajara olmaydi.")
    return new_status


def allowed_actions(status: OrderStatus, actor: Actor) -> list[Action]:
    """UI'da qaysi tugmalar ko'rinishini aniqlash uchun."""
    return [a for (s, a), (_, actors) in _TRANSITIONS.items() if s == status and actor in actors]


# ----------------------------------------- sotuvchi sozlamalari va usullar
@dataclass(frozen=True)
class SellerOptions:
    delivery: bool = False   # o'zi dostavka qiladi
    pickup: bool = True      # borib olishi mumkin
    taxi: bool = False       # taxi haydovchisiga berib yuborishga rozi


def available_methods(opts: SellerOptions) -> list[FulfillmentMethod]:
    methods: list[FulfillmentMethod] = []
    if opts.pickup:
        methods.append(FulfillmentMethod.PICKUP)
    if opts.taxi:
        methods.append(FulfillmentMethod.TAXI)
    if opts.delivery:
        methods.append(FulfillmentMethod.SELLER_DELIVERY)
    # MEETUP taklif sifatida doim mumkin: sotuvchi qabul qilish bilan hal qiladi
    methods.append(FulfillmentMethod.MEETUP)
    return methods


def ensure_method_available(opts: SellerOptions, method: FulfillmentMethod) -> None:
    if method not in available_methods(opts):
        raise MethodNotAvailable("Sotuvchi bu usulni qo'llamaydi.")


# Sotuvchi ro'yxatida so'rovlar tartibi (kichik raqam = tepada)
_PRIORITY = {
    FulfillmentMethod.PICKUP: 0,
    FulfillmentMethod.TAXI: 1,
    FulfillmentMethod.SELLER_DELIVERY: 2,
    FulfillmentMethod.MEETUP: 3,
}


def request_priority(method: FulfillmentMethod) -> int:
    return _PRIORITY[method]


# ------------------------------------------------ ko'rinish bosqichi (stage)
def stage_for(status: OrderStatus, method: FulfillmentMethod, actor: Actor) -> str:
    """Xaridor va sotuvchi uchun turli nom, bitta haqiqiy holat."""
    if status in ARCHIVED_STATUSES:
        return "archived"
    if status == OrderStatus.NEW:
        return "pending"
    # ACCEPTED
    if actor == Actor.SELLER:
        return "agreed"                 # "buyurtma yetkazilmoqda (kelishilgan)"
    if method == FulfillmentMethod.SELLER_DELIVERY:
        return "incoming"               # "kelishilgan buyurtma kelmoqda"
    return "pickup_in_progress"         # "olish jarayoni"


# --------------------------------------------------------- ogohlantirishlar
class Notice(str, Enum):
    NO_HANDOVER_WITHOUT_EXCHANGE = "no_handover_without_exchange"
    TAXI_BUYER_CALLS_TAXI = "taxi_buyer_calls_taxi"
    TAXI_BUYER_CONFIRMS_THEN_PAYS = "taxi_buyer_confirms_then_pays"
    TAXI_SELLER_HANDS_TO_DRIVER = "taxi_seller_hands_to_driver"


def notices_for(method: FulfillmentMethod, actor: Actor) -> list[Notice]:
    if actor == Actor.SYSTEM:
        return []
    if method == FulfillmentMethod.TAXI:
        if actor == Actor.BUYER:
            return [Notice.TAXI_BUYER_CALLS_TAXI, Notice.TAXI_BUYER_CONFIRMS_THEN_PAYS]
        return [Notice.TAXI_SELLER_HANDS_TO_DRIVER]
    return [Notice.NO_HANDOVER_WITHOUT_EXCHANGE]


# Matnlar taqdimot qatlamiga tegishli; shu yerda qulaylik uchun turibdi.
# Aniq so'zlarni o'zingiz tahrir qiling.
NOTICE_TEXTS_UZ: dict[Notice, str] = {
    Notice.NO_HANDOVER_WITHOUT_EXCHANGE:
        "Mahsulotni olmasdan to'lov qilmang, pulni olmasdan mahsulotni topshirmang.",
    Notice.TAXI_BUYER_CALLS_TAXI:
        "Taxini o'zingiz chaqiring va sotuvchining manzilini haydovchiga bering. Taxi haqini siz to'laysiz.",
    Notice.TAXI_BUYER_CONFIRMS_THEN_PAYS:
        "Haydovchi gulni olib kelgach, gulni olganingizni tasdiqlang, so'ng taxi to'lovini karta orqali qiling.",
    Notice.TAXI_SELLER_HANDS_TO_DRIVER:
        "Gulni faqat xaridor chaqirgan taxi haydovchisiga bering. Taxi haqini xaridor to'laydi.",
}


# --------------------------------------------------------------- sharh/baho
def can_review(status: OrderStatus, actor: Actor) -> bool:
    return status == OrderStatus.COMPLETED and actor == Actor.BUYER