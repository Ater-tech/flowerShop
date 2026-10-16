from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
from decimal import Decimal

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from carts.models import CartItem

from .domain.lifecycle import (
    Action, Actor, FulfillmentMethod, LifecycleError, OrderStatus,
    SellerOptions, ensure_method_available, transition,
)
from .domain.policies import account_kind, ensure_can_buy, ensure_not_own_shop
from .models import Order, OrderItem
from .selectors import shop_types_of


class EmptyCartError(LifecycleError):
    pass


class MissingSelectionError(LifecycleError):
    pass


class NotParticipantError(LifecycleError):
    pass


@dataclass(frozen=True)
class ShopSelection:
    """Xaridorning bitta do'kon bo'yicha tanlovi."""
    fulfillment_method: FulfillmentMethod
    meetup_note: str = ""
    desired_at: datetime | None = None
    delivery_fee: Decimal | None = Decimal("0")
    delivery_address: str = ""


def ensure_can_add_to_cart(*, user, shop) -> None:
    """Savatga qo'shishda: rasmiy do'kon xarid qila olmaydi, o'z mahsulotini ham olmaydi."""
    ensure_can_buy(account_kind(shop_types_of(user)))
    ensure_not_own_shop(buyer_id=user.id, shop_owner_id=shop.seller.user_id)


def seller_options(shop) -> SellerOptions:
    return SellerOptions(
        delivery=shop.allows_delivery,
        pickup=shop.allows_pickup,
        taxi=shop.allows_taxi,
    )


@transaction.atomic
def checkout(*, user, selections: dict[int, ShopSelection]) -> list[Order]:
    """Savatni do'konlar bo'yicha ajratib, har biriga alohida Order yaratadi."""
    ensure_can_buy(account_kind(shop_types_of(user)))
    cart_items = list(
        CartItem.objects.select_for_update(of=("self",))
        .filter(user=user)
        .select_related("product__shop__seller", "bouquet_composition__shop__seller")
    )
    if not cart_items:
        raise EmptyCartError("Savat bo'sh.")

    by_shop: dict[int, tuple[object, list[CartItem]]] = {}
    for item in cart_items:
        content = item.product if item.product_id else item.bouquet_composition
        shop = content.shop
        by_shop.setdefault(shop.pk, (shop, []))[1].append(item)

    # Avval hammasini tekshiramiz, keyin yaratamiz
    for shop_id, (shop, _) in by_shop.items():
        ensure_not_own_shop(buyer_id=user.id, shop_owner_id=shop.seller.user_id)
        selection = selections.get(shop_id)
        if selection is None:
            raise MissingSelectionError(f"Do'kon #{shop_id} uchun topshirish usuli tanlanmagan.")
        ensure_method_available(seller_options(shop), selection.fulfillment_method)

    ttl = timedelta(hours=getattr(settings, "ORDER_REQUEST_TTL_HOURS", 24))
    expires_at = timezone.now() + ttl

    created: list[Order] = []
    for shop_id, (shop, items) in by_shop.items():
        sel = selections[shop_id]
        order = Order.objects.create(
            buyer=user,
            shop=shop,
            total_price=0,
            fulfillment_method=sel.fulfillment_method.value,
            meetup_note=sel.meetup_note,
            desired_at=sel.desired_at,
            expires_at=expires_at,
            delivery_address=sel.delivery_address,
            delivery_fee=sel.delivery_fee if sel.delivery_fee is not None else Decimal("0"),
        )
        lines: list[OrderItem] = []
        total = Decimal("0")
        for item in items:
            if item.product_id:
                name, price = item.product.name, item.product.price
            else:
                name = f"Dasta #{item.bouquet_composition_id}"
                price = item.bouquet_composition.total_price
            lines.append(
                OrderItem(
                    order=order,
                    product=item.product,
                    bouquet_composition=item.bouquet_composition,
                    name_snapshot=name,
                    unit_price_snapshot=price,
                    quantity=item.quantity,
                    
                )
            )
            total += price * item.quantity
        OrderItem.objects.bulk_create(lines)
        order.total_price = total
        order.save(update_fields=["total_price"])
        created.append(order)

    CartItem.objects.filter(pk__in=[i.pk for i in cart_items]).delete()
    return created


def actor_for(order: Order, user) -> Actor:
    if user.id == order.buyer_id:
        return Actor.BUYER
    if user.id == order.shop.seller.user_id:
        return Actor.SELLER
    raise NotParticipantError("Buyurtma topilmadi.")


@transaction.atomic
def perform_action(*, order_id: int, user, action: Action) -> Order:
    order = (
        Order.objects.select_for_update(of=("self",))
        .select_related("shop__seller")
        .get(pk=order_id)
    )
    actor = actor_for(order, user)
    new_status = transition(OrderStatus(order.status), action, actor)
    order.status = new_status.value
    order.save(update_fields=["status", "updated_at"])
    return order


def expire_stale_orders(*, now=None) -> int:
    """Javobsiz qolgan NEW so'rovlarni EXPIRED qiladi. Cron/management command chaqiradi."""
    now = now or timezone.now()
    new_status = transition(OrderStatus.NEW, Action.EXPIRE, Actor.SYSTEM)
    return Order.objects.filter(
        status=OrderStatus.NEW.value, expires_at__isnull=False, expires_at__lt=now,
    ).update(status=new_status.value, updated_at=now)