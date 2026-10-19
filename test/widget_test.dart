import 'package:flutter_test/flutter_test.dart';
import 'package:lecturaia/main.dart';

void main() {
  testWidgets('LecturaIA muestra la pantalla inicial', (tester) async {
    await tester.pumpWidget(const LecturaIaApp());

    expect(find.text('LecturaIA'), findsOneWidget);
    expect(
      find.text('Tu biblioteca personal inteligente'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Descubre libros, guarda favoritos, comparte reseñas y recibe recomendaciones con IA.',
      ),
      findsOneWidget,
    );
  });
}
