from rest_framework import viewsets, permissions, filters
from django.db import transaction
from django.db.models import Exists, OuterRef
from django_filters.rest_framework import DjangoFilterBackend

from .models import ProductModel, ProductPricingConfig
from .serializers import ProductSerializer
from .exceptions import ProductLimitReached
from favourites.models import Favourite
from seller.models import Seller

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

        # print("========== FLOWER CREATE ==========")
        # print("SHOP ID:", shop.id)
        # print("SHOP TYPE:", shop.shop_type)
        # print("SHOP SELLER ID:", shop.seller_id)

        with transaction.atomic():
            seller = Seller.objects.select_for_update().get(pk=shop.seller_id)

            # print("SELLER ID:", seller.id)
            # print("PREMIUM:", seller.is_premium)
            # print("PAID SLOTS:", seller.paid_product_slots)

            if seller.is_premium:
                # print(">>> PREMIUM SAVE")
                serializer.save()
                # print(">>> PRODUCT SAVED")
                return

            if shop.shop_type == "business":
                # print(">>> BUSINESS")
                self._consume_slot_or_raise(seller)
            else:
                config = ProductPricingConfig.get_solo()

                used = ProductModel.objects.filter(
                    shop__seller=seller,
                    shop__shop_type="personal"
                ).count()

                # print(">>> PERSONAL")
                # print("USED:", used)
                # print("FREE LIMIT:", config.free_product_limit)

                if used >= config.free_product_limit:
                    # print(">>> FREE LIMIT REACHED")
                    self._consume_slot_or_raise(seller)

            # print(">>> BEFORE SERIALIZER SAVE")

            serializer.save()

            # print(">>> PRODUCT SAVED")
            
    def _consume_slot_or_raise(self, seller):
        if seller.paid_product_slots > 0:
            seller.paid_product_slots -= 1
            seller.save(update_fields=["paid_product_slots"])
        else:
            raise ProductLimitReached() 