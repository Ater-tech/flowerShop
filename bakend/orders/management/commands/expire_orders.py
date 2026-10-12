from django.core.management.base import BaseCommand

from orders.services import expire_stale_orders


class Command(BaseCommand):
    help = "Muddati o'tgan (javobsiz) buyurtma so'rovlarini EXPIRED holatiga o'tkazadi."

    def handle(self, *args, **options):
        count = expire_stale_orders()
        self.stdout.write(self.style.SUCCESS(f"{count} ta so'rov yopildi."))
