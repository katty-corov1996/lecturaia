import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/libros_controller.dart';
import '../controllers/favoritos_controller.dart';


class LibrosScreen extends StatelessWidget {
  const LibrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibrosController>();

final favoritos = Get.find<FavoritosController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
      ),
      body: Obx(
        () {
          switch (controller.estado.value) {
            case EstadoLibros.cargando:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case EstadoLibros.vacio:
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No hay libros disponibles.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );

            case EstadoLibros.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.mensajeError.value,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: controller.cargarLibros,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );

            case EstadoLibros.exito:
              return RefreshIndicator(
                onRefresh: controller.cargarLibros,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.libros.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final libro = controller.libros[index];

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          child: Icon(Icons.menu_book),
                        ),
                        title: Text(
                          libro.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),


trailing: Obx(
  () => IconButton(
    tooltip: favoritos.esFavorito(libro.id)
        ? 'Quitar de favoritos'
        : 'Agregar a favoritos',
    onPressed: () => favoritos.alternarFavorito(libro.id),
    icon: Icon(
      favoritos.esFavorito(libro.id)
          ? Icons.favorite
          : Icons.favorite_border,
    ),
  ),
),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${libro.autor}\n'
                            '${libro.genero} · ${libro.anio}',
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
