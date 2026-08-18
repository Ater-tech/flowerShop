from rest_framework import viewsets, permissions, filters
from django.db.models import Exists, OuterRef
from django_filters.rest_framework import DjangoFilterBackend

from .models import ProductModel
from .serializers import ProductSerializer
from favourites.models import Favourite


class FlowerViewSet(viewsets.ModelViewSet):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description"]
    ordering_fields = ["price", "rating_avg", "sold_count", "created_at"]
    filterset_fields = ["shop", "shop__city", "shop__shop_type"]

    def get_queryset(self):
        qs = ProductModel.objects.select_related("shop", "shop__city", "shop__seller").order_by("-created_at")

        premium_only = self.request.query_params.get("premium_sellers")
        if premium_only == "true":
            qs = qs.filter(shop__seller__is_premium=True)

        user = self.request.user
        if user.is_authenticated:
            qs = qs.annotate(
                is_fav_annotated=Exists(
                    Favourite.objects.filter(user=user, flower=OuterRef("pk"))
                )
            )
        return qs

    def perform_create(self, serializer):
        shop = serializer.validated_data["shop"]

        with transaction.atomic():
            # Seller qatorini lock qilamiz - parallel so'rovlar
            # bitta paid_product_slot'ni ikki marta ishlatib qo'ymasligi uchun
            seller = Seller.objects.select_for_update().get(pk=shop.seller_id)

            if seller.is_premium:
                serializer.save()
                return

            if shop.shop_type == "business":
                # Business uchun bepul reklama yo'q - darhol slot yoki premium kerak
                self._consume_slot_or_raise(seller)
            else:
                # Personal - avval bepul limitni tekshiramiz
                config = ProductPricingConfig.get_solo()
                used = ProductModel.objects.filter(
                    shop__seller=seller, shop__shop_type="personal"
                ).count()

                if used >= config.free_product_limit:
                    self._consume_slot_or_raise(seller)

            serializer.save()

    def _consume_slot_or_raise(self, seller):
        if seller.paid_product_slots > 0:
            seller.paid_product_slots -= 1
            seller.save(update_fields=["paid_product_slots"])
        else:
            raise ProductLimitReached()