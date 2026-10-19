import 'package:get/get.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  AuthController({AuthService? servicio})
      : _servicio = servicio ?? AuthService();

  final AuthService _servicio;

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  final RxBool cargando = false.obs;
  final RxString mensajeError = ''.obs;

  bool get estaAutenticado => usuario.value != null;

  @override
  void onInit() {
    super.onInit();
    restaurarSesion();
  }

  Future<void> restaurarSesion() async {
    cargando.value = true;
    mensajeError.value = '';

    try {
      final tieneSesion = await _servicio.tieneSesion();

      if (!tieneSesion) {
        usuario.value = null;
        return;
      }

      usuario.value = await _servicio.obtenerUsuarioGuardado();
    } catch (_) {
      usuario.value = null;
      mensajeError.value = 'No se pudo restaurar la sesión.';
    } finally {
      cargando.value = false;
    }
  }

  Future<void> cerrarSesion() async {
    await _servicio.eliminarToken();
    usuario.value = null;
  }
}
