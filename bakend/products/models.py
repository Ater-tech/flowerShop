from django.db import models

class ShopAsistense(models.Model):
    # id = models.BigAutoField(primary_key=True)
    firstname = models.CharField(max_length=50)
    surname = models.CharField(max_length=50)
    phone_number = models.DecimalField(max_digits=7, decimal_places=0)
    photo = models.ImageField(upload_to="asistenses/")
    reg_date = models.DateTimeField(auto_now_add=True)
    info = models.TextField(max_length = 1500)
    
    def __str__(self):
        return self.firstname
    
class ProductModel(models.Model):
    # id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=50, help_text= "Enter the name of the flower", default="No named")
    shop_name = models.CharField(max_length=50)
    image = models.ImageField(upload_to="images/")
    description = models.TextField(max_length=1500)
    location = models.TextField(max_length=50)
    # shopAsistense = models.ManyToManyField(ShopAsistense)
    price = models.DecimalField(max_digits=12, decimal_places=3)
    aviable = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_favourite = models.BooleanField(default=False)
    def __str__(self):
        return self.name  

