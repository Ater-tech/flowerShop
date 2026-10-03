# So'rov (query) mantiqi shu yerda, view'lar esa ingichka. Bu Flutter'dagi
# repository qatlamining backend'dagi o'xshashi.
from datetime import timedelta

from django.db.models import Count, Exists, F, OuterRef, Q, Subquery, Value
from django.db.models.functions import Coalesce
from django.utils import timezone

from favourites.models import Favourite  # TODO: sizdagi haqiqiy yo'l
from products.models import ProductModel, ProductPromotion


def _active_promotions():
    now = timezone.now()
    return ProductPromotion.objects.filter(starts_at__lte=now, ends_at__gt=now)


def _base_queryset():
    return ProductModel.objects.select_related(
        "shop", "shop__city", "shop__seller", "shop__seller__user"
    )


def annotate_card_fields(qs, user=None):
    """
    Mahsulot kartochkasi uchun kerakli annotate'lar.
    rating_avg endi modelning haqiqiy maydoni, uni qayta annotatsiya qilmaymiz.
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
    """Reklama birinchi, keyin reyting, keyin sotilganlar soni."""
    return annotate_card_fields(_base_queryset(), user).order_by(
        "-is_promoted",
        F("rating_avg").desc(nulls_last=True),  # reytingsizlar oxirida
        "-sold_count",
        "-id",  # barqaror tartib
    )[:limit]

def my_products(user):
    """
    "Mening mahsulotlarim" tabi uchun: foydalanuvchining barcha do'konlaridagi
    mahsulotlar, faol/mavjudlari tepada, sotilgan/nofaollari pastda —
    har ikki guruh ichida eng yangisi birinchi.
    """
    return (
        ProductModel.objects.filter(shop__seller__user=user)
        .select_related("shop")
        .annotate(
            _inactive_rank=Case(
                When(status="active", available=True, then=Value(0)),
                default=Value(1),
                output_field=IntegerField(),
            )
        )
        .order_by("_inactive_rank", "-created_at")
    )