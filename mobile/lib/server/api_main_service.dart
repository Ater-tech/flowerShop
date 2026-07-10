import 'package:dio/dio.dart';
import 'package:mobile/repository/auth_interceptor.dart';
import 'package:mobile/repository/auth_reprository.dart';
import 'package:mobile/repository/token_storage.dart';
import 'package:mobile/server/api_endpoints.dart';

class ApiMainService {
  final TokenStorage storage;
  late final AuthReprository reprository;
  ApiMainService({required this.storage}) {
    
    // with interceptor
    dio.options = _createDio().options;

    // for refresh

    refreshDio.options = _createDio().options;

    reprository = AuthReprository(
      refreshDio: refreshDio, 
      storage: storage);

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        requestHeader: true,
        responseBody: false,
        responseHeader: false,
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(
        storage: storage, 
        reprository: reprository, 
        api: dio)
    );

  }

  // with intercepter
  final Dio dio = Dio();

  // for refresh
  final Dio refreshDio = Dio();
}

Dio _createDio() => Dio(
  BaseOptions(
    headers: {"Content-Type": "application/json"},
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ),
);
