from django.db import migrations
41504872160042

CITIES = [
    'Toshkent',
    'Samarqand',
    'Buxoro',
    'Andijon',
    'Farg\'ona',
    'Namangan',
    'Qarshi',
    'Nukus',
    'Urganch',
    'Termiz',
    'Jizzax',
    'Guliston',
    'Navoiy',
]


def seed_cities(apps, schema_editor):
    City = apps.get_model('city', 'City')
    for name in CITIES:
        City.objects.get_or_create(name=name)


def reverse_seed(apps, schema_editor):
    City = apps.get_model('city', 'City')
    City.objects.filter(name__in=CITIES).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('city', '0001_initial'),  # o'zingizdagi oxirgi migratsiya nomiga moslang
    ]

    operations = [
        migrations.RunPython(seed_cities, reverse_seed),
    ]