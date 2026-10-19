import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lecturaia/controllers/auth_controller.dart';
import 'package:lecturaia/main.dart';
import 'package:lecturaia/models/usuario.dart';
import 'package:lecturaia/services/auth_service.dart';

class AuthServiceFake extends AuthService {
  @override
  Future<Usuario?> obtenerUsuarioGuardado() async {
    return null;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;

    Get.put(
      AuthController(
        servicio: AuthServiceFake(),
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'LecturaIA muestra la pantalla de inicio de sesión',
    (tester) async {
      await tester.pumpWidget(const LecturaIaApp());

      await tester.pump();
      await tester.pump();

      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Bienvenido a LecturaIA'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Ingresar'), findsOneWidget);
    },
  );
}
