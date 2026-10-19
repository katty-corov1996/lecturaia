import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'controllers/libros_controller.dart';
import 'screens/libros_screen.dart';



void main() {
  Get.put(AuthController());
Get.put(LibrosController());

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

GetPage(
  name: '/libros',
  page: () => const LibrosScreen(),
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
