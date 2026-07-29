import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/storage/token_storage.dart';
import 'package:mobile/server/api_endpoints.dart';

class UserRepository {
  final Dio api;
  final TokenStorage storage;
  
  UserRepository({
    required this.api,
    required this.storage,
  });
  
  Future<bool> deleteAccount() async {
    try {
      await api.delete(ApiEndpoints.deleteAccount);
      await storage.deleteTokensAndRememberMe();
      return true;
    } on DioException catch(e){
      debugPrint("Cannot Delete error $e");
      return false;
    }
  }

  Future<UserModel?> getProfile() async{
    try{
      final response = await api.get(ApiEndpoints.getUserProfile,);
      return UserModel.fromJson(response.data);
    } on DioException catch(e){
      debugPrint("Cannot get profile info $e");
      return null;
    }    
  }

  Future<bool> updateProfile(UserModel user) async{
    try{
      await api.post(ApiEndpoints.updateUserProfile, data: user);
      return true; 
    } on DioException catch(e){
      debugPrint("Update error: $e");
      return false;
    }
  }
}