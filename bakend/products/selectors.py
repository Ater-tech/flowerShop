from datetime import timedelta
from django.db.models import Count, Exists, F, OuterRef, Subquery, Value, Q
from django.db.models.functions import Coalesce
from django.utils import timezone

from products.models import ProductModel, ProductPromotion
from favourites.models import Favourite


def _active_promotions():
    now = timezone.now()
    return ProductPromotion.objects.filter(starts_at__lte=now, ends_at__gt=now)


def _base_queryset():
    # TODO: Flutter'dagi ProductModel shop'ni ichida kutadi -> select_related('shop')
    return ProductModel.objects.select_related("shop")  # + .filter(is_active=True), agar bor bo'lsa


def annotate_card_fields(qs, user=None):
    """
    Mahsulot kartochkasi uchun kerakli annotate'lar.
    Reyting Subquery orqali olinadi (JOIN emas): weekly_sold_count'dagi Count
    bilan birga JOIN qilinsa qatorlar ko'payib ketishi (fan-out) mumkin edi.
    Subquery'da bunday xavf umuman yo'q.
    """
    active = _active_promotions().filter(product=OuterRef("pk"))
    week_ago = timezone.now() - timedelta(days=7)
    qs = qs.annotate(
        is_promoted=Exists(active),
        weekly_sold_count=Count(
            "sale_logs",
            filter=Q(sale_logs__sold_at__gte=week_ago),
            distinct=True,
        ),
    )
    if user is not None and user.is_authenticated:
        qs = qs.annotate(
            is_fav_annotated=Exists(
                Favourite.objects.filter(user=user, flower=OuterRef("pk"))
            )
        )
    return qs


def recommended_products(limit: int, user=None):
    """Faqat faol reklama. Priority bo'yicha, teng bo'lsa tasodifiy (adolatli aylanish)."""
    active = _active_promotions().filter(product=OuterRef("pk"))
    priority = Subquery(active.order_by("-priority").values("priority")[:1])
    return (
        annotate_card_fields(_base_queryset(), user)
        .filter(is_promoted=True)
        .annotate(promo_priority=Coalesce(priority, Value(0)))
        .order_by("-promo_priority", "?")[:limit]
    )


def popular_products(limit: int, user=None):
    """Reklama birinchi, keyin reyting, keyin qidiruv soni."""
    return annotate_card_fields(_base_queryset(), user).order_by(
        "-is_promoted",
        F("rating_avg").desc(nulls_last=True),  # reytingsizlar oxirida
        "-sold_count",
        "-id",  # barqaror tartib
    )[:limit]