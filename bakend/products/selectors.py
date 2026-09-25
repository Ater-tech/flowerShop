# So'rov (query) mantiqi shu yerda, view'lar esa ingichka. Bu Flutter'dagi
# repository qatlamining backend'dagi o'xshashi.
from django.db.models import Exists, F, OuterRef, Subquery, Value, Count, Q
from django.db.models.functions import Coalesce
from django.utils import timezone
from datetime import timedelta

from products.models import ProductModel, ProductPromotion


def _active_promotions():
    now = timezone.now()
    return ProductPromotion.objects.filter(starts_at__lte=now, ends_at__gt=now)


def _base_queryset():
    # TODO: Flutter'dagi ProductModel shop'ni ichida kutadi -> select_related('shop')
    return ProductModel.objects.select_related("shop", "shop__city", "shop__seller", "shop__seller__user")  # + .filter(is_active=True), agar bor bo'lsa


def annotate_card_fields(qs):
    """
    Mahsulot kartochkasi uchun kerakli annotate'lar.
    Reyting Subquery orqali olinadi (JOIN emas): weekly_sold_count'dagi Count
    bilan birga JOIN qilinsa qatorlar ko'payib ketishi (fan-out) mumkin edi.
    Subquery'da bunday xavf umuman yo'q.
    """
    active = _active_promotions().filter(product=OuterRef("pk"))
    week_ago = timezone.now() - timedelta(days=7)    
    qs.annotate(
        is_promoted=Exists(active),
        rating_avg=Subquery(avg_rating),        
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


def recommended_products(limit: int):
    """Faqat faol reklama. Priority bo'yicha, teng bo'lsa tasodifiy (adolatli aylanish)."""
    active = _active_promotions().filter(product=OuterRef("pk"))
    priority = Subquery(active.order_by("-priority").values("priority")[:1])
    return (
        annotate_card_fields(_base_queryset())
        .filter(is_promoted=True)
        .annotate(promo_priority=Coalesce(priority, Value(0)))
        .order_by("-promo_priority", "?")[:limit]
    )


def popular_products(limit: int):
    """Reklama birinchi, keyin reyting, keyin qidiruv soni."""
    return annotate_card_fields(_base_queryset()).order_by(
        "-is_promoted",
        F("rating_avg").desc(nulls_last=True),  # reytingsizlar oxirida
        "-search_count",
        "-id",  # barqaror tartib
    )[:limit]