# seller/services.py (yoki shunga o'xshash joy) uchun.
from django.db import transaction
from django.utils import timezone

from carts.models import CartItem
from orders.domain.policies import ensure_can_upgrade_to_business
from orders.selectors import has_active_orders
from seller.models import Seller
from shop.models import Shop


@transaction.atomic
def upgrade_to_business(*, user) -> None:
    """
    Shaxsiy sotuvchini rasmiy do'konga o'tkazadi.
    Eski buyurtmalar tarixi ko'rinmas bo'ladi (history_cleared_at), savat tozalanadi.
    Boshqa foydalanuvchilarning buyurtma ma'lumotlari o'chirilmaydi.
    """
    seller = Seller.objects.select_for_update().get(user=user)
    shops = Shop.objects.filter(seller=seller)
    shop_types = set(shops.values_list("shop_type", flat=True))

    ensure_can_upgrade_to_business(shop_types=shop_types, has_active_orders=has_active_orders(user))

    shops.update(shop_type="business")
    seller.history_cleared_at = timezone.now()
    seller.save(update_fields=["history_cleared_at"])
    CartItem.objects.filter(user=user).delete()   # rasmiy do'kon xarid qila olmaydi


# seller/views.py uchun:
#
# class UpgradeToBusinessView(APIView):
#     permission_classes = [permissions.IsAuthenticated]
#
#     def post(self, request):
#         if request.data.get("confirm") is not True:
#             return Response({"detail": "Tasdiqlash kerak.", "code": "confirm_required"}, status=400)
#         try:
#             upgrade_to_business(user=request.user)
#         except Seller.DoesNotExist:
#             return Response({"detail": "Sotuvchi profili yo'q.", "code": "not_a_seller"}, status=404)
#         except NotPersonalSellerError as e:
#             return Response({"detail": str(e), "code": "not_personal_seller"}, status=403)
#         except ActiveOrdersError as e:
#             return Response({"detail": str(e), "code": "active_orders"}, status=409)
#         return Response({"detail": "Rasmiy do'konga o'tdingiz."})