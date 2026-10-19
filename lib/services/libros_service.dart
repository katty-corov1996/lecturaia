import '../models/libro.dart';
import 'api_client.dart';

class LibrosService {
  LibrosService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Libro>> listarLibros() async {
    final respuesta = await _api.dio.get('/libros');

    final datos = respuesta.data as List;

    return datos
        .map(
          (item) => Libro.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
