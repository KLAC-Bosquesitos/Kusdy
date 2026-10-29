import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/auth/data/auth_repository_falso.dart';
import 'package:kusdy/features/auth/presentation/auth_providers.dart';
import 'package:kusdy/features/mas/presentation/mas_screen.dart';

void main() {
  testWidgets('cada opción de Más abre su pantalla y se puede volver', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepositoryFalso(conSesion: true),
          ),
        ],
        child: const MaterialApp(home: MasScreen()),
      ),
    );

    for (final opcion in ['Productos', 'Reportes', 'Usuarios']) {
      await tester.tap(find.text(opcion));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, opcion), findsOne);
      expect(find.text('Próximamente'), findsOne);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Más'), findsOne);
    }
  });
}
