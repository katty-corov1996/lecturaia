import 'package:flutter_test/flutter_test.dart';
import 'package:lecturaia/main.dart';

void main() {
  testWidgets('LecturaIA muestra la pantalla de inicio de sesión',
      (tester) async {
    await tester.pumpWidget(const LecturaIaApp());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Bienvenido a LecturaIA'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
