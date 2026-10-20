import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/libros_controller.dart';
import '../controllers/resenas_controller.dart';



class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  late final ResenasController resenasController;
  late final LibrosController librosController;

  @override
  void initState() {
    super.initState();

    resenasController = Get.find<ResenasController>();
    librosController = Get.find<LibrosController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      resenasController.cargarResenas();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reseñas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarFormulario(
            context,
            resenasController,
            librosController,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva reseña'),
      ),
      body: Obx(() {
        switch (resenasController.estado.value) {
          case EstadoResenas.cargando:
            return const Center(
              child: CircularProgressIndicator(),
            );

          case EstadoResenas.vacio:
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no has creado reseñas.',
                  textAlign: TextAlign.center,
                ),
              ),
            );

          case EstadoResenas.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resenasController.mensajeError.value,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed:
                          resenasController.cargarResenas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );

          case EstadoResenas.exito:
            return RefreshIndicator(
              onRefresh:
                  resenasController.cargarResenas,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount:
                    resenasController.resenas.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final resena =
                      resenasController.resenas[index];

                  final libro = librosController.libros
                      .where(
                        (item) =>
                            item.id == resena.libroId,
                      )
                      .firstOrNull;

                  return Card(
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(16),
                      title: Text(
                        libro?.titulo ??
                            'Libro ${resena.libroId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(resena.comentario),
                            const SizedBox(height: 8),
                            Text(
                              'Calificación: '
                              '${resena.calificacion}/5',
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'Eliminar reseña',
                        icon:
                            const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final eliminada =
                              await resenasController
                                  .eliminarResena(
                            resena.id,
                          );

                          if (eliminada) {
                            Get.snackbar(
                              'Reseña eliminada',
                              'La reseña se eliminó correctamente.',
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
        }
      }),
    );
  }

  void _mostrarFormulario(
    BuildContext context,
    ResenasController resenasController,
    LibrosController librosController,
  ) {
    final comentarioController =
        TextEditingController();

    int? libroId;
    int calificacion = 5;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva reseña'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Libro',
                      ),
                      initialValue: libroId,
                      items: librosController.libros
                          .map(
                            (libro) =>
                                DropdownMenuItem<int>(
                              value: libro.id,
                              child: Text(
                                libro.titulo,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        setState(() {
                          libroId = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller:
                          comentarioController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText: 'Comentario',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Calificación',
                      ),
                      initialValue: calificacion,
                      items: List.generate(
                        5,
                        (index) {
                          final valor = index + 1;

                          return DropdownMenuItem<int>(
                            value: valor,
                            child: Text('$valor / 5'),
                          );
                        },
                      ),
                      onChanged: (valor) {
                        if (valor != null) {
                          setState(() {
                            calificacion = valor;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final comentario =
                        comentarioController.text.trim();

                    if (libroId == null) {
                      Get.snackbar(
                        'Dato requerido',
                        'Selecciona un libro.',
                      );
                      return;
                    }

                    if (comentario.length < 3) {
                      Get.snackbar(
                        'Comentario inválido',
                        'Escribe un comentario de al menos 3 caracteres.',
                      );
                      return;
                    }

                    final creada =
                        await resenasController
                            .crearResena(
                      libroId: libroId!,
                      comentario: comentario,
                      calificacion: calificacion,
                    );

                    if (creada) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      Get.snackbar(
                        'Reseña guardada',
                        'La reseña se creó correctamente.',
                      );
                    } else {
                      Get.snackbar(
                        'No se pudo guardar',
                        resenasController
                            .mensajeError.value,
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
