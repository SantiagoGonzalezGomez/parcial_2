// FILE: lib/services/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class DioClient {
  late final Dio _dio;

  DioClient() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[DIO] $o'),
      ),
    );
  }

  Dio get dio => _dio;
}

// Dio separado para la API de accidentes (sin baseUrl fijo)
final accidentDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Accept': 'application/json'},
    ),
  );
});

// ignore: avoid_print
void debugPrint(String msg) => print(msg);