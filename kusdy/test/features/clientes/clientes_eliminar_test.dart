import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/domain/cliente.dart';
import 'package:kusdy/features/clientes/domain/filtro_clientes.dart';
import 'package:kusdy/features/clientes/presentation/clientes_providers.dart';
import 'package:kusdy/features/clientes/presentation/clientes_screen.dart';

Widget pantallaCon(ClientesRepositoryFalso repositorio) {
  return ProviderScope(
    overrides: [clientesRepositoryProvider.overrideWithValue(repositorio)],
    child: MaterialApp(home: const ClientesScreen()),
  );
}

// Desliza la tarjeta del cliente hacia la izquierda, como con el dedo.
Future<void> deslizar(WidgetTester tester, String id) async {
  await tester.drag(find.byKey(ValueKey(id)), const Offset(-600, 0));
  await dejarPasar(tester);
}

// Deja pasar 2 segundos cuadro por cuadro. No se usa pumpAndSettle porque,
// mientras se espera a la base, no hay animación y se detendría antes de
// que la base responda.
Future<void> dejarPasar(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// Pregunta directo al repositorio qué quedó guardado. runAsync usa el reloj
// real: con el reloj de la prueba, el Future.delayed nunca terminaría.
Future<List<Cliente>> consultarBase(
  WidgetTester tester,
  ClientesRepositoryFalso repositorio,
) async {
  final clientes = await tester.runAsync(
    () => repositorio.obtenerClientes(const FiltroClientes()),
  );
  return clientes!;
}

void main() {
  testWidgets('deslizar borra en la base y Deshacer lo regresa idéntico', (
    tester,
  ) async {
    final repositorio = ClientesRepositoryFalso(demora: Duration.zero);
    await tester.pumpWidget(pantallaCon(repositorio));
    await tester.pumpAndSettle();
    expect(find.text('Hotel Los Altos'), findsOne);

    await deslizar(tester, '3');

    expect(find.text('Hotel Los Altos'), findsNothing);
    expect(find.text('Se eliminó a Hotel Los Altos.'), findsOne);
    // Se borró en la base, no solo en la pantalla.
    final enLaBase = await consultarBase(tester, repositorio);
    expect(enLaBase.map((c) => c.id), isNot(contains('3')));

    await tester.tap(find.text('Deshacer'));
    await dejarPasar(tester);

    // Vuelve el mismo registro: mismo id, mismos datos.
    expect(find.byKey(const ValueKey('3')), findsOne);
    expect(find.text('Hotel Los Altos'), findsOne);
    expect(find.text('7761 2030 · Calentador solar 300 L'), findsOne);
    final restaurados = await consultarBase(tester, repositorio);
    expect(restaurados.map((c) => c.id), contains('3'));
  });

  testWidgets('si la base falla al borrar, la fila vuelve', (tester) async {
    final repositorio = ClientesRepositoryFalso(
      modo: ModoFalso.fallaBorrar,
      demora: Duration.zero,
    );
    await tester.pumpWidget(pantallaCon(repositorio));
    await tester.pumpAndSettle();

    await deslizar(tester, '3');

    expect(find.text('Hotel Los Altos'), findsOne);
    expect(find.textContaining('No se pudo eliminar'), findsOne);
    expect(find.text('Deshacer'), findsNothing);
  });
}
