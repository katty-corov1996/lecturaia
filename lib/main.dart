import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  Get.put(AuthController());

  runApp(const LecturaIaApp());
}

class LecturaIaApp extends StatelessWidget {
  const LecturaIaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'LecturaIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.temaClaro,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
      ],
      home: Obx(
        () {
          if (auth.cargando.value) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return auth.estaAutenticado
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
