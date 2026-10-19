import 'package:dio/dio.dart';

import '../models/resena.dart';
import 'api_client.dart';

class ResenasService {
  final Dio _dio = ApiClient().dio;

  Future<List<Resena>> obtenerMisResenas() async {
    final response = await _dio.get('/resenas/mias');

    final datos = response.data as List<dynamic>;

    return datos
        .map(
          (item) => Resena.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Resena> crearResena({
    required int libroId,
    required String comentario,
    required int calificacion,
  }) async {
    final response = await _dio.post(
      '/resenas',
      data: {
        'libro_id': libroId,
        'comentario': comentario,
        'calificacion': calificacion,
      },
    );

    return Resena.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> eliminarResena(int resenaId) async {
    await _dio.delete('/resenas/$resenaId');
  }
}
