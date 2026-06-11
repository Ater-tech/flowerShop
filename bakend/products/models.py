from django.db import models

class ProductModel(models.Model):
    name = models.CharField(max_length=50)
    shop_name = models.CharField(max_length=50)
    image = models.ImageField(upload_to="images/")
    description = models.TextField(max_length=1500)
    location = models.TextField(max_length=50)
    price = models.DecimalField(max_digits=12, decimal_places=3)
    aviable = models.BooleanField()
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name  

