from django.db.models import Case, IntegerField, Value, When
from .models import Order

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