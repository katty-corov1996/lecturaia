import 'package:dio/dio.dart';

import 'api_client.dart';

class IaService {
  final Dio _dio = ApiClient().dio;

  Future<String> recomendarLectura(
    String preferencias,
  ) async {
    final response = await _dio.post(
      '/ia/recomendar',
      data: {
        'preferencias': preferencias,
      },
    );

    final data = response.data as Map<String, dynamic>;

    return data['recomendacion'] as String;
  }
}
