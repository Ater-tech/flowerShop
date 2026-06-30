from django.shortcuts import render
from rest_framework import serializers
from .models import User
# Create your views here.

class RegSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "email",
            "password",
        ]
        extra_kwargs = {
            "password": {
                "write_only" : True,
            }
        }
    
    def create(self, validated_data):
        return User.objects.create_user(**validated_data)