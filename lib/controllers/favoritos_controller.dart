import 'package:get/get.dart';
import 'package:hive/hive.dart';

class FavoritosController extends GetxController {
  static const String _nombreCaja = 'favoritos';
  static const String _claveIds = 'libros_favoritos';

  Box<dynamic>? _caja;

  final RxSet<int> favoritos = <int>{}.obs;
  final RxBool cargando = true.obs;

  @override
  void onInit() {
    super.onInit();
    iniciar();
  }

  Future<void> iniciar() async {
    cargando.value = true;

    _caja = await Hive.openBox(_nombreCaja);

    final guardados = _caja?.get(
      _claveIds,
      defaultValue: <dynamic>[],
    );

    if (guardados is List) {
      favoritos.assignAll(
        guardados.map((id) => id as int),
      );
    }

    cargando.value = false;
  }

  bool esFavorito(int libroId) {
    return favoritos.contains(libroId);
  }

  Future<void> alternarFavorito(int libroId) async {
    if (favoritos.contains(libroId)) {
      favoritos.remove(libroId);
    } else {
      favoritos.add(libroId);
    }

    await _guardar();
  }

  Future<void> _guardar() async {
    await _caja?.put(
      _claveIds,
      favoritos.toList(),
    );
  }
}
