class Shop(models.Model):
    name = models.CharField(max_length=100)
    address = models.CharField(max_length=250)
    city = models.ForeignKey(City, on_delete=models.CASCADE, related_name='shops')
    seller = models.ForeignKey(Seller, on_delete=models.CASCADE, related_name='shops')
    latitude = models.FloatField()
    longitude = models.FloatField()
    is_default = models.BooleanField(default=False)

    SHOP_TYPE_CHOICES = [
        ('personal', 'Shaxsiy'),
        ('business', "Rasmiy do'kon"),
    ]
    shop_type = models.CharField(
        max_length=10, choices=SHOP_TYPE_CHOICES, default='personal'
    )
    # ...save() metodi avvalgidek qoladi