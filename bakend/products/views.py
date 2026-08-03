from django.shortcuts import render
from django.http import JsonResponse, response
from .models import ProductModel, ProductPricingConfig
from .serializers import ProductSerializer
from favourites.models import Favourite
from .exceptions import ProductLimitReached
from rest_framework import viewsets, permissions, filters
from django.db.models import Exists, OuterRef
from django_filters.rest_framework import DjangoFilterBackend

class FlowerViewSet(viewsets.ModelViewSet):
    serializer_class = ProductSerializer
    queryset = ProductModel.objects.all().order_by("created_at")
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description"]
    ordering_fields = ["price", "rating_avg", "sold_count", "created_at"]
    filterset_fields = ["city", "seller"]

    def perform_create(self, serializer):
        seller = self.request.user.seller_profile  # User -> Seller OneToOne/ForeignKey
        serializer.save(seller=seller)

    def get_queryset(self):
        qs = ProductModel.objects.select_related("seller", "city")
        
        premium_only = self.request.query_params.get("premium_sellers")
        if premium_only == "true":
            qs = qs.filter(seller__is_premium =True)
            
        user = self.request.user
        if user.is_authenticated:
            qs = qs.annotate(
                is_fav_annotated=Exists(
                    Favourite.objects.filter(user=user, flower=OuterRef("pk"))
                )
            )
        return qs
    
    
# def FlowerInfo(request):
#     items = ProductModel.objects.all()
#     data = []

#     for flower in items:
#         data.append({
#             'name': flower.name,
#             'shop_name': flower.shop_name,
#             'image': request.build_absolute_uri(
#                 flower.image.url
#                 ),
#             'description': flower.description,
#             'location': flower.location,
#             'price': str(flower.price),
#             'created': str(flower.created),
#             'aviable': flower.aviable,
#         })
    
#     return JsonResponse(data, safe=False)