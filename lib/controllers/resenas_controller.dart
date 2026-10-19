import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/resena.dart';
import '../services/resenas_service.dart';

enum EstadoResenas {
  cargando,
  exito,
  vacio,
  error,
}

class ResenasController extends GetxController {
  final ResenasService _service = ResenasService();

  final RxList<Resena> resenas = <Resena>[].obs;
  final Rx<EstadoResenas> estado = EstadoResenas.cargando.obs;
  final RxString mensajeError = ''.obs;
  final RxBool guardando = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargarResenas();
  }

  Future<void> cargarResenas() async {
    estado.value = EstadoResenas.cargando;
    mensajeError.value = '';

    try {
      final resultado = await _service.obtenerMisResenas();

      resenas.assignAll(resultado);

      estado.value = resultado.isEmpty
          ? EstadoResenas.vacio
          : EstadoResenas.exito;
    } on DioException catch (e) {
      estado.value = EstadoResenas.error;

      if (e.response?.statusCode == 401) {
        mensajeError.value =
            'Tu sesión ha expirado. Inicia sesión nuevamente.';
      } else if (e.response?.statusCode == 500) {
        mensajeError.value =
            'El servidor presentó un problema.';
      } else {
        mensajeError.value =
            'No se pudieron cargar tus reseñas.';
      }
    } catch (_) {
      estado.value = EstadoResenas.error;
      mensajeError.value =
          'Ocurrió un error inesperado.';
    }
  }

  Future<bool> crearResena({
    required int libroId,
    required String comentario,
    required int calificacion,
  }) async {
    guardando.value = true;
    mensajeError.value = '';

    try {
      final nueva = await _service.crearResena(
        libroId: libroId,
        comentario: comentario,
        calificacion: calificacion,
      );

      resenas.insert(0, nueva);
      estado.value = EstadoResenas.exito;

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        mensajeError.value =
            'Tu sesión ha expirado.';
      } else if (e.response?.statusCode == 404) {
        mensajeError.value =
            'El libro seleccionado no existe.';
      } else if (e.response?.statusCode == 422) {
        mensajeError.value =
            'Revisa el comentario y la calificación.';
      } else {
        mensajeError.value =
            'No se pudo guardar la reseña.';
      }

      return false;
    } catch (_) {
      mensajeError.value =
          'Ocurrió un error inesperado.';
      return false;
    } finally {
      guardando.value = false;
    }
  }

  Future<bool> eliminarResena(int resenaId) async {
    try {
      await _service.eliminarResena(resenaId);

      resenas.removeWhere(
        (resena) => resena.id == resenaId,
      );

      if (resenas.isEmpty) {
        estado.value = EstadoResenas.vacio;
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        mensajeError.value =
            'Tu sesión ha expirado.';
      } else if (e.response?.statusCode == 404) {
        mensajeError.value =
            'La reseña ya no existe.';
      } else {
        mensajeError.value =
            'No se pudo eliminar la reseña.';
      }

      return false;
    } catch (_) {
      mensajeError.value =
          'Ocurrió un error inesperado.';
      return false;
    }
  }
}
