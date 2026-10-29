import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/app/app.dart';
import 'package:kusdy/app/pestana.dart';
import 'package:kusdy/features/auth/data/auth_repository_falso.dart';
import 'package:kusdy/features/auth/presentation/auth_providers.dart';

// La app completa con sus repositorios falsos de siempre y una sesión ya
// iniciada (sin Supabase). pumpAndSettle avanza el reloj de la prueba hasta
// que terminan los Future.delayed.
Future<ProviderContainer> abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          AuthRepositoryFalso(conSesion: true),
        ),
      ],
      child: const KusdyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(KusdyApp)));
}

Future<void> tocarPestana(WidgetTester tester, String nombre) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(nombre),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre en Hoy', (tester) async {
    final contenedor = await abrirApp(tester);

    expect(contenedor.read(pestanaProvider), Pestana.hoy);
    expect(find.widgetWithText(AppBar, 'Clientes para hoy'), findsOne);
  });

  testWidgets('cada botón de la barra cambia de pantalla', (tester) async {
    final contenedor = await abrirApp(tester);

    await tocarPestana(tester, 'Clientes');
    expect(contenedor.read(pestanaProvider), Pestana.clientes);
    expect(find.widgetWithText(AppBar, 'Clientes'), findsOne);

    await tocarPestana(tester, 'Agenda');
    expect(contenedor.read(pestanaProvider), Pestana.agenda);
    expect(find.widgetWithText(AppBar, 'Agenda'), findsOne);

    await tocarPestana(tester, 'Más');
    expect(contenedor.read(pestanaProvider), Pestana.mas);
    expect(find.widgetWithText(AppBar, 'Más'), findsOne);

    await tocarPestana(tester, 'Hoy');
    expect(find.widgetWithText(AppBar, 'Clientes para hoy'), findsOne);
  });

  testWidgets('"Ver todos los clientes" en Hoy lleva a la pestaña Clientes', (
    tester,
  ) async {
    final contenedor = await abrirApp(tester);

    await tester.tap(find.byTooltip('Ver todos los clientes'));
    await tester.pumpAndSettle();

    expect(contenedor.read(pestanaProvider), Pestana.clientes);
    expect(find.widgetWithText(AppBar, 'Clientes'), findsOne);
    // Sigue la barra: no se abrió una pantalla encima.
    expect(find.byType(NavigationBar), findsOne);
  });
}
