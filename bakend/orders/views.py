from collections import defaultdict
from django.db import transaction
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from carts.models import CartItem
from .models import Order, OrderItem
from .selectors import buyer_orders
from .serializers import OrderSerializer

class CheckoutView(APIView):
    """
    Joriy foydalanuvchining butun savatini buyurtmaga aylantiradi.
    Savatda bir nechta do'kondan mahsulot bo'lsa, har bir do'kon uchun
    ALOHIDA Order yaratiladi.
    """
    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        cart_items = list(
            CartItem.objects.filter(user=request.user).select_related(
                "product", "product__shop", "bouquet_composition", "bouquet_composition__shop"
            )
        )
        if not cart_items:
            return Response({"detail": "Savat bo'sh."}, status=400)

        by_shop = defaultdict(list)
        for item in cart_items:
            shop = item.product.shop if item.product_id else item.bouquet_composition.shop
            by_shop[shop].append(item)

        created_orders = []
        for shop, items in by_shop.items():
            order = Order.objects.create(shop=shop, buyer=request.user, total_price=0)
            total = 0
            order_items = []
            for item in items:
                if item.product_id:
                    name, price = item.product.name, item.product.price
                else:
                    name = f"Dasta #{item.bouquet_composition_id}"
                    price = item.bouquet_composition.total_price

                order_items.append(
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

            OrderItem.objects.bulk_create(order_items)
            order.total_price = total
            order.save(update_fields=["total_price"])
            created_orders.append(order)

        CartItem.objects.filter(pk__in=[i.pk for i in cart_items]).delete()
        return Response(OrderSerializer(created_orders, many=True).data, status=201)

class OrderListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return buyer_orders(self.request.user)

class OrderDetailView(generics.RetrieveAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(buyer=self.request.user).prefetch_related("items")