from rest_framework import status
from rest_framework.generics import  CreateAPIView, RetrieveUpdateDestroyAPIView
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated  
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import User
from .serializers import RegisterSerializer, ChangePasswordSerializer, ProfileSerializer

class RegisterView(CreateAPIView):
    permission_classes = [AllowAny,]
    queryset = User.objects.all()

    serializer_class = RegisterSerializer
    
class ProfileView(RetrieveUpdateDestroyAPIView):
    """
    GET    /api/users/me/  — profil
    PATCH  /api/users/me/  — ism, shahar, avatar (multipart yoki JSON)
    DELETE /api/users/me/  — akkauntni o'chirish (soft delete)
    """

    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    http_method_names = ["get", "patch", "delete", "head", "options"]

    def get_object(self):
        return self.request.user

    def perform_destroy(self, instance):
        # Hard delete o'rniga is_active=False: buyurtmalar tarixi saqlanadi,
        # SimpleJWT esa nofaol foydalanuvchini avtomatik rad etadi.
        instance.is_active = False
        instance.save(update_fields=["is_active"])


class ChangePasswordView(APIView):
    """POST /api/users/me/change-password/"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"detail": "Parol muvaffaqiyatli o'zgartirildi."},
            status=status.HTTP_200_OK,
        )