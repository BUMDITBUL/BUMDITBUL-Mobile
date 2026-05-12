import 'package:bumditbul_mobile/core/network/api_endpoint.dart';
import 'package:bumditbul_mobile/core/network/auth_interceptor.dart';
import 'package:bumditbul_mobile/core/network/logging_interceptor.dart';
import 'package:bumditbul_mobile/core/services/token_storage.dart';
import 'package:dio/dio.dart';

class DioClient {
  late final Dio dio;

  DioClient(TokenStorage tokenStorage) {
    final options = BaseOptions(
      baseUrl: ApiEndpoint.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    );

    final refreshDio = Dio(options)..interceptors.add(LoggingInterceptor());

    dio = Dio(options);
    dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(tokenStorage: tokenStorage, refreshDio: refreshDio),
    ]);
  }
}
