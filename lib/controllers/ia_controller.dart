import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../services/ia_service.dart';
import 'package:flutter/foundation.dart';

class IaController extends GetxController {
  final IaService _service = IaService();

  final RxBool cargando = false.obs;
  final RxString recomendacion = ''.obs;
  final RxString mensajeError = ''.obs;

  Future<void> obtenerRecomendacion(
    String preferencias,
  ) async {
    final texto = preferencias.trim();

    if (texto.isEmpty) {
      mensajeError.value =
          'Describe primero tus preferencias de lectura.';
      recomendacion.value = '';
      return;
    }

    cargando.value = true;
    mensajeError.value = '';
    recomendacion.value = '';

    try {
      final resultado =
          await _service.recomendarLectura(texto);

      recomendacion.value = resultado;
    } on DioException catch (e) {
      debugPrint(
        'IA ERROR: tipo=${e.type}, '
        'mensaje=${e.message}, '
        'url=${e.requestOptions.uri}, '
        'status=${e.response?.statusCode}, '
        'data=${e.response?.data}',
      );


      if (e.response?.statusCode == 400) {
        mensajeError.value =
            'Debes indicar tus preferencias de lectura.';
      } else if (e.response?.statusCode == 401) {
        mensajeError.value =
            'Tu sesión ha expirado. Inicia sesión nuevamente.';
      } else if (e.response?.statusCode == 502) {
        mensajeError.value =
            'El servicio de inteligencia artificial no respondió correctamente.';
      } else if (e.response?.statusCode == 503) {
        mensajeError.value =
            'No se pudo conectar con el servicio de inteligencia artificial.';
      } else {
        mensajeError.value =
            'No se pudo generar la recomendación.';
      }
    } catch (_) {
      mensajeError.value =
          'Ocurrió un error inesperado.';
    } finally {
      cargando.value = false;
    }

  }

  void limpiar() {
    recomendacion.value = '';
    mensajeError.value = '';
  }
}
