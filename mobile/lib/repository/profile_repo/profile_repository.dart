import 'dart:io';

import 'package:dio/dio.dart';

import 'package:mobile/error_handler/error_result.dart';
import 'package:mobile/error_handler/failure.dart';
import 'package:mobile/error_handler/dio_failure_mapper.dart';
import 'package:mobile/models/profile_info/profile_model.dart';

class ProfileRepository {
  const ProfileRepository(this._dio);

  /// apiMainServiceProvider orqali olingan markaziy Dio (bare Dio() EMAS).
  final Dio _dio;

  static const _mePath = '/api/users/me/';
  static const _passwordPath = '/api/users/me/change-password/';

  Future<Result<ProfileModel>> fetchProfile() async {
    try {
      final res = await _dio.get(_mePath);
      return Success(ProfileModel.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Future<Result<ProfileModel>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    File? avatar,
  }) async {
    try {
      final form = FormData.fromMap({
        'first_name': ?firstName,
        'last_name': ?lastName,
        'phone_number': ?phoneNumber,
        if (avatar != null)
          'avatar': await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split(Platform.pathSeparator).last,
          ),
      });
      final res = await _dio.patch(_mePath, data: form);
      return Success(ProfileModel.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Future<Result<bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(_passwordPath, data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      return Success(true);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Future<Result<bool>> deleteAccount() async {
    try {
      await _dio.delete(_mePath);
      return Success(true);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  /// 400 javobdagi DRF xabarini ({"field": ["xabar"]}) ajratib oladi,
  /// qolgan holatlarda mavjud mapDioExceptionToFailure ishlaydi.
  Failure _mapError(DioException e) {
    final data = e.response?.data;
    if (e.response?.statusCode == 400 && data is Map && data.isNotEmpty) {      
      return ValidationFailure(Map<String, dynamic>.from(data));
    }
    return mapDioExceptionToFailure(e);
  }
}