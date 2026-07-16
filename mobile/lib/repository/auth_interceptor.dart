import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobile/repository/token_repository.dart';
import 'package:mobile/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage, required this.reprository, required this.api});
  final TokenStorage storage;
  final TokenRepository reprository;
  final Dio api;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final options = err.requestOptions;

    // retry error handler
    if (options.extra["retry"] == true) {
      return handler.next(err);
    }

    if (_refreshCompleter != null) {
      final token = await _refreshCompleter!.future;
      if (token == null) {
        return handler.next(err);
      }
      options.headers["Authorization"] = "Bearer $token";
      options.extra["retry"] = true;
      final response = await api.fetch(options);
        
      handler.resolve(response);
    }

    _refreshCompleter = Completer<String?>();

    final newToken = await reprository.refreshToken();

    _refreshCompleter!.complete(newToken);
    _refreshCompleter = null;
    if (newToken == null) {
      return handler.next(err);
    }
    return _retry(options, newToken, handler);
  }

  Future<void> _retry(
    RequestOptions options,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    options.headers["Authorization"] = "Bearer $token";
    options.extra["retry"] = true;
    try{
      final response = await api.fetch(options);
      handler.resolve(response);
    } on DioException catch(e){
      handler.next(e);
    }
  }
}
