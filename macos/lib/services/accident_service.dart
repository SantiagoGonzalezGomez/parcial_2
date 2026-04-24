// FILE: lib/services/accident_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/accident_model.dart';
import 'dio_client.dart';

final accidentServiceProvider = Provider<AccidentService>((ref) {
  final dio = ref.watch(accidentDioProvider);
  return AccidentService(dio);
});

class AccidentService {
  final Dio _dio;

  AccidentService(this._dio);

  Future<List<AccidentModel>> fetchAccidents() async {
    final baseUrl = dotenv.env['ACCIDENTS_URL'] ??
        'https://www.datos.gov.co/resource/ezt8-5wyj.json';
    final limit = dotenv.env['ACCIDENTS_LIMIT'] ?? '100000';

    final response = await _dio.get(
      baseUrl,
      queryParameters: {'\$limit': limit},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => AccidentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error al cargar accidentes: ${response.statusCode}');
  }
}