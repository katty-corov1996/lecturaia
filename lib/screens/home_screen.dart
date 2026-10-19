import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LecturaIA'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await auth.cerrarSesion();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(
        () {
          final usuario = auth.usuario.value;

          if (usuario == null) {
            return const Center(
              child: Text('No hay una sesión activa.'),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 90,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hola, ${usuario.nombre}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    usuario.email,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tu biblioteca inteligente está lista para comenzar.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
