import 'package:dio/dio.dart';
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
      usuario.value = await _servicio.obtenerUsuarioGuardado();
    } catch (_) {
      usuario.value = null;
      mensajeError.value = 'No se pudo restaurar la sesión.';
    } finally {
      cargando.value = false;
    }
  }

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    cargando.value = true;
    mensajeError.value = '';

    try {
      await _servicio.iniciarSesion(
        email: email.trim(),
        password: password,
      );

      usuario.value = await _servicio.obtenerUsuarioActual();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        mensajeError.value = 'Correo o contraseña incorrectos.';
      } else {
        mensajeError.value =
            'No se pudo iniciar sesión. Inténtalo nuevamente.';
      }
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    cargando.value = true;
    mensajeError.value = '';

    try {
      await _servicio.registrar(
        nombre: nombre.trim(),
        email: email.trim(),
        password: password,
      );

      await _servicio.iniciarSesion(
        email: email.trim(),
        password: password,
      );

      usuario.value = await _servicio.obtenerUsuarioActual();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        mensajeError.value = 'El correo ya está registrado.';
      } else {
        mensajeError.value =
            'No se pudo completar el registro.';
      }
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<void> cerrarSesion() async {
    await _servicio.eliminarToken();
    usuario.value = null;
  }
}
