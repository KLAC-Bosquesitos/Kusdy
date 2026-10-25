import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/core/utils/fechas.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/presentation/clientes_providers.dart';
import 'package:kusdy/features/clientes/presentation/clientes_screen.dart';

// El repositorio falso de la app, sin esperas. Los datos de ejemplo tienen
// 2 clientes de este mes, 2 del mes pasado y 1 de hace dos meses.
Future<void> abrirClientes(WidgetTester tester) async {
  // Pantalla del tamaño de un celular, para que quepan las 5 tarjetas.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientesRepositoryProvider.overrideWithValue(
          ClientesRepositoryFalso(demora: Duration.zero),
        ),
      ],
      child: const MaterialApp(home: ClientesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> elegirMes(WidgetTester tester, String texto) async {
  await tester.tap(find.byKey(const Key('filtro-mes')));
  await tester.pumpAndSettle();
  // El menú abierto repite el texto elegido: se toca el último.
  await tester.tap(find.text(texto).last);
  await tester.pumpAndSettle();
}

void main() {
  final hoy = DateTime.now();
  final esteMes = mesYAnio(DateTime(hoy.year, hoy.month));
  final mesPasado = mesYAnio(DateTime(hoy.year, hoy.month - 1));
  final haceCincoMeses = mesYAnio(DateTime(hoy.year, hoy.month - 5));

  testWidgets('al elegir un mes, la lista cambia sola', (tester) async {
    await abrirClientes(tester);
    expect(find.byType(Dismissible), findsNWidgets(5));

    await elegirMes(tester, esteMes);
    expect(find.text('María López'), findsOne);
    expect(find.text('José Pérez'), findsOne);
    expect(find.text('Hotel Los Altos'), findsNothing);

    await elegirMes(tester, mesPasado);
    expect(find.text('Hotel Los Altos'), findsOne);
    expect(find.text('Ana Gómez'), findsOne);
    expect(find.text('María López'), findsNothing);

    await elegirMes(tester, 'Todos los meses');
    expect(find.byType(Dismissible), findsNWidgets(5));
  });

  testWidgets('la búsqueda filtra por nombre y por teléfono', (tester) async {
    await abrirClientes(tester);

    await tester.enterText(find.byType(TextField), 'hotel');
    await tester.pumpAndSettle();
    expect(find.text('Hotel Los Altos'), findsOne);
    expect(find.byType(Dismissible), findsOne);

    await tester.enterText(find.byType(TextField), '4021');
    await tester.pumpAndSettle();
    expect(find.text('José Pérez'), findsOne);
    expect(find.byType(Dismissible), findsOne);
  });

  testWidgets('filtro sin resultados: vacío según el filtro y Quitar filtros', (
    tester,
  ) async {
    await abrirClientes(tester);

    await elegirMes(tester, haceCincoMeses);
    expect(find.text('No hay clientes con estos filtros.'), findsOne);
    // No es el vacío de "no tienes clientes".
    expect(find.text('Aún no tienes clientes.'), findsNothing);

    await tester.tap(find.text('Quitar filtros'));
    await tester.pumpAndSettle();
    expect(find.byType(Dismissible), findsNWidgets(5));
    expect(find.text('Todos los meses'), findsOne);
  });
}
