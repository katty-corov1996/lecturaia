import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/libro.dart';
import '../services/libros_service.dart';

enum EstadoLibros {
  cargando,
  exito,
  vacio,
  error,
}

class LibrosController extends GetxController {
  LibrosController({LibrosService? servicio})
      : _servicio = servicio ?? LibrosService();

  final LibrosService _servicio;

  final RxList<Libro> libros = <Libro>[].obs;
  final Rx<EstadoLibros> estado = EstadoLibros.cargando.obs;
  final RxString mensajeError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    estado.value = EstadoLibros.cargando;
    mensajeError.value = '';

    try {
      final resultado = await _servicio.listarLibros();

      libros.assignAll(resultado);

      if (libros.isEmpty) {
        estado.value = EstadoLibros.vacio;
      } else {
        estado.value = EstadoLibros.exito;
      }
    } on DioException catch (e) {
      libros.clear();

      if (e.response?.statusCode == 401) {
        mensajeError.value = 'Tu sesión ha expirado.';
      } else if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 500) {
        mensajeError.value = 'El servidor no está disponible.';
      } else {
        mensajeError.value =
            'No se pudieron cargar los libros.';
      }

      estado.value = EstadoLibros.error;
    }
  }
}
