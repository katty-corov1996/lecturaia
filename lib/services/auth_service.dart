import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario.dart';

class AuthService {
  AuthService();

  static const _claveToken = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
    return null;
  }
}
