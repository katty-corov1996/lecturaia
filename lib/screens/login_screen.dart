import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
final AuthController _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

Future<void> _iniciarSesion() async {
  if (!_formKey.currentState!.validate()) return;

  final correcto = await _auth.iniciarSesion(
    email: _correoController.text,
    password: _claveController.text,
  );

  if (!mounted) return;

  if (correcto) {
Get.offAllNamed('/home');

    Get.snackbar(
      'LecturaIA',
      'Inicio de sesión correcto.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } else {
    Get.snackbar(
      'Error',
      _auth.mensajeError.value,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bienvenido a LecturaIA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu correo electrónico.';
                      }
                      if (!valor.contains('@')) {
                        return 'Ingresa un correo válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _claveController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Ingresa tu contraseña.';
                      }
                      if (valor.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

Obx(
  () => FilledButton(
    onPressed: _auth.cargando.value ? null : _iniciarSesion,
    child: _auth.cargando.value
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : const Text('Ingresar'),
  ),
),

const SizedBox(height: 12),
TextButton(
  onPressed: () => Get.toNamed('/registro'),
  child: const Text('Crear una cuenta'),
),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
