// FILE: lib/services/establishment_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/establishment_model.dart';
import 'dio_client.dart';

final establishmentServiceProvider = Provider<EstablishmentService>((ref) {
  final client = ref.watch(dioClientProvider);
  return EstablishmentService(client.dio);
});

class EstablishmentService {
  final Dio _dio;

  EstablishmentService(this._dio);

  // GET /establecimientos
  Future<List<EstablishmentModel>> fetchAll() async {
    final response = await _dio.get('/establecimientos');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => EstablishmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /establecimientos/{id}
  Future<EstablishmentModel> fetchById(String id) async {
    final response = await _dio.get('/establecimientos/$id');
    return EstablishmentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  // POST /establecimientos (multipart)
  Future<EstablishmentModel> create({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    final formData = FormData.fromMap({
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      if (logoPath != null)
        'logo': await MultipartFile.fromFile(logoPath,
            filename: logoPath.split('/').last),
    });

    final response = await _dio.post('/establecimientos', data: formData);
    return EstablishmentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  // POST /establecimiento-update/{id} con _method=PUT (multipart)
  Future<EstablishmentModel> update({
    required String id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    final formData = FormData.fromMap({
      '_method': 'PUT',
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      if (logoPath != null)
        'logo': await MultipartFile.fromFile(logoPath,
            filename: logoPath.split('/').last),
    });

    final response = await _dio.post(
      '/establecimiento-update/$id',
      data: formData,
    );
    return EstablishmentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  // DELETE /establecimientos/{id}
  Future<void> delete(String id) async {
    await _dio.delete('/establecimientos/$id');
  }
}