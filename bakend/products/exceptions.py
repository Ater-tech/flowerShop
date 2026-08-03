# products/exceptions.py
from rest_framework.exceptions import APIException
from rest_framework import status

class ProductLimitReached(APIException):
    status_code = status.HTTP_402_PAYMENT_REQUIRED  # to'lov talab qilinishini bildiradi
    default_detail = {
        "code": "product_limit_reached",
        "message": "Bepul mahsulot qo'shish limiti tugadi. Premium sotib oling yoki har bir mahsulot uchun to'lang.",
        "options": ["premium", "pay_per_product"],
        "price_per_product": 5000,
    }
    default_code = "product_limit_reached"