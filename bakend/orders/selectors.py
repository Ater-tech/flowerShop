from django.db.models import Case, IntegerField, Value, When
from .models import Order
    
from django.db.models import Case, IntegerField, Q, Value, When

from seller.models import Seller

from .domain.lifecycle import (
    ACTIVE_STATUSES, ARCHIVED_STATUSES, FulfillmentMethod, request_priority,
)
from shop.models import Shop

from .models import Order, OrderItem

def buyer_orders(user):
    """
    Faol buyurtmalar tepada, bajarilgan/bekor qilinganlar pastda —
    har ikki guruh ichida eng yangisi birinchi.
    """
    return (
        Order.objects.filter(buyer=user)
        .select_related("shop")
        .prefetch_related("items")
        .annotate(
            _inactive_rank=Case(
                When(status__in=Order.COMPLETED_STATUSES, then=Value(1)),
                default=Value(0),
                output_field=IntegerField(),
            )
        )
        .order_by("_inactive_rank", "-created_at")
    )

_ARCHIVED = [s.value for s in ARCHIVED_STATUSES]


def _base():
    return (
        Order.objects.select_related("buyer", "shop", "shop__seller")
        .prefetch_related("items")
        .annotate(
            archived_rank=Case(
                When(status__in=_ARCHIVED, then=Value(1)),
                default=Value(0),
                output_field=IntegerField(),
            )
        )
    )


def _apply_history_cutoff(qs, user):
    """Rasmiy do'konga o'tgan sotuvchining eski tarixi ko'rinmaydi."""
    cleared_at = (
        Seller.objects.filter(user=user).values_list("history_cleared_at", flat=True).first()
    )
    return qs.filter(created_at__gte=cleared_at) if cleared_at else qs


def buyer_orders(user):
    """Xaridor oynasi: faol tepada, arxiv pastda, ichida yangisi birinchi."""
    qs = _base().filter(buyer=user)
    return _apply_history_cutoff(qs, user).order_by("archived_rank", "-created_at")


def seller_orders(user, *, product_id: int | None = None):
    """Sotuvchi oynasi: faol tepada; ichida olib ketish → taxi → dostavka → uchrashuv."""
    method_rank = Case(
        *[
            When(fulfillment_method=m.value, then=Value(request_priority(m)))
            for m in FulfillmentMethod
        ],
        default=Value(99),
        output_field=IntegerField(),
    )
    qs = _base().filter(shop__seller__user=user).annotate(method_rank=method_rank)
    qs = _apply_history_cutoff(qs, user)
    if product_id is not None:
        qs = qs.filter(
            pk__in=OrderItem.objects.filter(product_id=product_id).values("order_id")
        )
    return qs.order_by("archived_rank", "method_rank", "-created_at")


def order_for_participant(user, pk: int):
    """Buyurtmani faqat uning xaridori yoki sotuvchisi ko'ra oladi."""
    qs = _base().filter(Q(buyer=user) | Q(shop__seller__user=user)).filter(pk=pk)
    return _apply_history_cutoff(qs, user)


def shop_types_of(user) -> set[str]:
    """Foydalanuvchining barcha do'konlari turlari (masalan {"personal", "business"})."""
    return set(Shop.objects.filter(seller__user=user).values_list("shop_type", flat=True))


def has_active_orders(user) -> bool:
    """Foydalanuvchining xaridor yoki sotuvchi sifatidagi tugallanmagan buyurtmasi bormi."""
    active = [st.value for st in ACTIVE_STATUSES]
    return Order.objects.filter(
        Q(buyer=user) | Q(shop__seller__user=user), status__in=active
    ).exists()