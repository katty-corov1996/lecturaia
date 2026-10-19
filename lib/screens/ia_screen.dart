import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ia_controller.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final _preferenciasController = TextEditingController();

  final IaController _iaController =
      Get.find<IaController>();

  @override
  void dispose() {
    _preferenciasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendación con IA'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 72,
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Qué te gustaría leer?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Describe tus géneros, temas o tipos de historias favoritas.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _preferenciasController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Preferencias de lectura',
                  hintText:
                      'Ejemplo: misterio, ciencia ficción y aventura...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => FilledButton.icon(
                  onPressed: _iaController.cargando.value
                      ? null
                      : () {
                          _iaController.obtenerRecomendacion(
                            _preferenciasController.text,
                          );
                        },
                  icon: _iaController.cargando.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _iaController.cargando.value
                        ? 'Generando...'
                        : 'Obtener recomendación',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () {
                  if (_iaController
                      .mensajeError.value.isNotEmpty) {
                    return Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _iaController
                                    .mensajeError.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_iaController
                      .recomendacion.value.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.menu_book),
                              SizedBox(width: 8),
                              Text(
                                'Tu recomendación',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

SelectableText(
  _iaController.recomendacion.value
      .replaceAll('**', '')
      .replaceAll('* ', '• ')
      .replaceAll('*', ''),
),



                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
