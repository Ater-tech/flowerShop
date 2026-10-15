from django.db.models import Q
from django.http import Http404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .domain.lifecycle import (
    Action, ActionNotAllowed, FulfillmentMethod, InvalidTransition, MethodNotAvailable,
)
from .domain.policies import (
    RoleNotAllowedError, SelfPurchaseError, account_kind, available_tabs, can_buy,
)
from .models import Order
from .selectors import buyer_orders, order_for_participant, seller_orders, shop_types_of
from .serializers import CheckoutSerializer, OrderSerializer
from .services import (
    EmptyCartError, MissingSelectionError, NotParticipantError, ShopSelection,
    checkout, perform_action,
)

_ERRORS = [
    (SelfPurchaseError, status.HTTP_403_FORBIDDEN, "self_purchase"),
    (RoleNotAllowedError, status.HTTP_403_FORBIDDEN, "role_not_allowed"),
    (ActionNotAllowed, status.HTTP_403_FORBIDDEN, "action_not_allowed"),
    (NotParticipantError, status.HTTP_404_NOT_FOUND, "not_found"),
    (InvalidTransition, status.HTTP_409_CONFLICT, "invalid_transition"),
    (MethodNotAvailable, status.HTTP_400_BAD_REQUEST, "method_not_available"),
    (EmptyCartError, status.HTTP_400_BAD_REQUEST, "empty_cart"),
    (MissingSelectionError, status.HTTP_400_BAD_REQUEST, "missing_selection"),
]


def error_response(exc: Exception) -> Response:
    for cls, http_status, code in _ERRORS:
        if isinstance(exc, cls):
            return Response({"detail": str(exc), "code": code}, status=http_status)
    raise exc


class CheckoutView(APIView):
    """
    Savatni buyurtmalarga aylantiradi: har bir do'kon uchun alohida Order.
    Body: {"orders": [{"shop": 3, "fulfillment_method": "pickup",
                       "meetup_note": "", "desired_at": null}, ...]}
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        ser = CheckoutSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        selections = {
            row["shop"]: ShopSelection(
                fulfillment_method=FulfillmentMethod(row["fulfillment_method"]),
                meetup_note=row["meetup_note"].strip(),
                desired_at=row["desired_at"],
                delivery_address=row["delivery_address"].strip(),
                delivery_fee=row["delivery_fee"],
            )
            for row in ser.validated_data["orders"]
        }
        try:
            orders = checkout(user=request.user, selections=selections)
        except Exception as exc:
            return error_response(exc)
        data = OrderSerializer(orders, many=True, context={"request": request}).data
        return Response(data, status=status.HTTP_201_CREATED)


class OrderListView(generics.ListAPIView):
    """Xaridor oynasi (Sotib olinganlar)."""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return buyer_orders(self.request.user)


class SellerOrderListView(generics.ListAPIView):
    """Sotuvchi oynasi. Ixtiyoriy: ?product=<id> — shu mahsulotga kelgan so'rovlar."""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        raw = self.request.query_params.get("product")
        product_id = int(raw) if raw and raw.isdigit() else None
        return seller_orders(self.request.user, product_id=product_id)


class OrderDetailView(generics.RetrieveAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return order_for_participant(self.request.user, self.kwargs["pk"])


class OrderActionView(APIView):
    """POST /api/orders/<pk>/actions/<accept|reject|cancel|complete>/"""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk: int, action: str):
        try:
            act = Action(action)
        except ValueError:
            raise Http404
        try:
            perform_action(order_id=pk, user=request.user, action=act)
        except Order.DoesNotExist:
            raise Http404
        except Exception as exc:
            return error_response(exc)
        order = order_for_participant(request.user, pk).get()
        return Response(OrderSerializer(order, context={"request": request}).data)


class OrderMetaView(APIView):
    """Flutter uchun: qaysi oynalar ko'rinadi va xarid qila oladimi."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        types = shop_types_of(request.user)
        kind = account_kind(types)
        return Response(
            {"account_kind": kind.value, "can_buy": can_buy(kind), "tabs": available_tabs(types)}
        )
