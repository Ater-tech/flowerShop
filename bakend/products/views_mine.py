from rest_framework import generics, permissions
from products.selectors import my_products
from products.serializers import ProductSerializer  # Loyihangizdagi serializer

class MyProductsView(generics.ListAPIView):
    """GET /api/product/mine/ — joriy foydalanuvchining do'kon(lar)idagi mahsulotlari."""
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        return my_products(self.request.user)