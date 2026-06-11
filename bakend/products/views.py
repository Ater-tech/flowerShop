from django.shortcuts import render
from django.http import JsonResponse
from .models import ProductModel
# Create your views here.

def FlowerInfo(request):
    items = ProductModel.objects.all()
    data = []

    for flower in items:
        data.append({
            'name': flower.name,
            'shop_name': flower.shop_name,
            'image': request.build_absolute_uri(
                flower.image.url
                ),
            'description': flower.description,
            'location': flower.location,
            'price': str(flower.price),
            'created': str(flower.created),
            'aviable': flower.aviable,
        })
    
    return JsonResponse(data, safe=False)