import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favoritos_controller.dart';
import '../controllers/libros_controller.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final librosController = Get.find<LibrosController>();
    final favoritosController = Get.find<FavoritosController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: Obx(
        () {
          final favoritos = librosController.libros
              .where(
                (libro) =>
                    favoritosController.esFavorito(libro.id),
              )
              .toList();

          if (favoritosController.cargando.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (favoritos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no tienes libros favoritos.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favoritos.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final libro = favoritos[index];

              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    child: Icon(Icons.favorite),
                  ),
                  title: Text(
                    libro.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 8),
                    child: Text(
                      '${libro.autor}\n'
                      '${libro.genero} · ${libro.anio}',
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Quitar de favoritos',
                    onPressed: () =>
                        favoritosController.alternarFavorito(
                      libro.id,
                    ),
                    icon: const Icon(
                      Icons.favorite,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
