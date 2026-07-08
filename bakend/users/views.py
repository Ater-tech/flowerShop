from rest_framework.generics import  CreateAPIView
from rest_framework.permissions import AllowAny  
from .models import User
from .serializers import RegisterSerializer

class RegisterView(CreateAPIView):
    permission_classes = [AllowAny,]
    queryset = User.objects.all()

    serializer_class = RegisterSerializer
    
