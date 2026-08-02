import 'package:dio/dio.dart';
import 'package:mobile/repository/auth_interceptor.dart';
import 'package:mobile/repository/auth_reprository.dart';
import 'package:mobile/repository/city_repository.dart';
import 'package:mobile/repository/product_repository.dart';
import 'package:mobile/storage/token_storage.dart';
import 'package:mobile/repository/user_repository.dart';
import 'package:mobile/server/api_endpoints.dart';
import 'package:mobile/repository/token_repository.dart';

class ApiMainService {
  final TokenStorage storage;
  // with intercepter
  final Dio dio = _createDio();
  // for refresh
  final Dio refreshDio = _createDio();

  late final TokenRepository tokenRepository;
  late final AuthReprository authReprository;
  late final UserRepository userReprository;
  late final CityRepository cityReprository;
  late final ProductRepository productRepository;

  ApiMainService({required this.storage}) {
    _initRepositories();
    _initInterceptors();
  }

  void _initRepositories() {
    tokenRepository = TokenRepository(refreshDio: refreshDio, storage: storage);
    authReprository = AuthReprository(api: dio, storage: storage);
    userReprository = UserRepository(api: dio, storage: storage);
    cityReprository = CityRepository(dio: dio, storage: storage);
    productRepository = ProductRepository(dio: dio, storage: storage);
  }

  void _initInterceptors() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(storage: storage, reprository: tokenRepository, api: dio),
    );
  }
}

Dio _createDio() => Dio(
  BaseOptions(
    headers: {"Content-Type": "application/json"},
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ),
);
