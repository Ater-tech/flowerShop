from django.db.models import Avg
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import Review


def _recalculate_seller_rating(product):
    seller = product.shop.seller
    avg = Review.objects.filter(product__shop__seller=seller).aggregate(
        avg=Avg("rating")
    )["avg"]
    seller.rating_avg = round(avg or 0, 2)
    seller.save(update_fields=["rating_avg"])


@receiver(post_save, sender=Review)
def update_rating_on_save(sender, instance, **kwargs):
    _recalculate_seller_rating(instance.product)


@receiver(post_delete, sender=Review)
def update_rating_on_delete(sender, instance, **kwargs):
    _recalculate_seller_rating(instance.product)