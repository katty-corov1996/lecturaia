import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  static const _claveToken = 'access_token';

  final ApiClient _api;
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final respuesta = await _api.dio.post(
      '/auth/registro',
      data: {
        'nombre': nombre,
        'email': email,
        'password': password,
      },
    );

    return Usuario.fromJson(
      Map<String, dynamic>.from(respuesta.data as Map),
    );
  }

  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final respuesta = await _api.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final datos =
        Map<String, dynamic>.from(respuesta.data as Map);

    final token = datos['access_token'] as String;

    await guardarToken(token);
  }

  Future<Usuario> obtenerUsuarioActual() async {
    final respuesta = await _api.dio.get('/auth/me');

    return Usuario.fromJson(
      Map<String, dynamic>.from(respuesta.data as Map),
    );
  }

  Future<void> guardarToken(String token) async {
    await _storage.write(
      key: _claveToken,
      value: token,
    );
  }

  Future<String?> obtenerToken() async {
    return _storage.read(key: _claveToken);
  }

  Future<void> eliminarToken() async {
    await _storage.delete(key: _claveToken);
  }

  Future<bool> tieneSesion() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  Future<Usuario?> obtenerUsuarioGuardado() async {
    final tieneToken = await tieneSesion();

    if (!tieneToken) {
      return null;
    }

    try {
      return await obtenerUsuarioActual();
    } on DioException {
      await eliminarToken();
      return null;
    }
  }
}
