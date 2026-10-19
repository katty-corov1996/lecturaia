import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/inicio_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LecturaIaApp());
}

class LecturaIaApp extends StatelessWidget {
  const LecturaIaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LecturaIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.temaClaro,
      home: const InicioScreen(),
    );
  }
}
