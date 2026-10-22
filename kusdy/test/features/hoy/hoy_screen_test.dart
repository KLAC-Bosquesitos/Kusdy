import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/hoy/data/hoy_repository_falso.dart';
import 'package:kusdy/features/hoy/domain/hoy_repository.dart';
import 'package:kusdy/features/hoy/domain/pendiente_hoy.dart';
import 'package:kusdy/features/hoy/presentation/hoy_providers.dart';
import 'package:kusdy/features/hoy/presentation/hoy_screen.dart';

// Repositorio de prueba: responde lo que cada prueba quiera, sin esperas.
class HoyDePrueba implements HoyRepository {
  HoyDePrueba(this.respuesta);

  Future<List<PendienteHoy>> Function() respuesta;

  @override
  Future<List<PendienteHoy>> obtenerPendientesDeHoy() => respuesta();
}

Widget pantallaCon(HoyRepository repositorio) {
  return ProviderScope(
    overrides: [hoyRepositoryProvider.overrideWithValue(repositorio)],
    child: const MaterialApp(home: HoyScreen()),
  );
}

void main() {
  testWidgets('error: mensaje para personas y botón Reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(
      pantallaCon(HoyDePrueba(() async => throw Exception('sin red'))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No pudimos cargar tus pendientes'), findsOne);
    expect(find.text('Reintentar'), findsOne);
    expect(find.textContaining('sin red'), findsNothing);
  });

  testWidgets('error -> Reintentar -> datos', (tester) async {
    final repositorio = HoyDePrueba(() async => throw Exception('sin red'));
    await tester.pumpWidget(pantallaCon(repositorio));
    await tester.pumpAndSettle();

    repositorio.respuesta = () async => pendientesDeEjemplo;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('María López'), findsOne);
  });

  testWidgets('cargando -> datos', (tester) async {
    final lectura = Completer<List<PendienteHoy>>();
    await tester.pumpWidget(pantallaCon(HoyDePrueba(() => lectura.future)));

    expect(find.text('Revisando tu día…'), findsOne);

    lectura.complete(pendientesDeEjemplo);
    await tester.pumpAndSettle();

    expect(find.text('Hotel Los Altos'), findsOne);
  });

  testWidgets('vacío: ofrece ver todos los clientes', (tester) async {
    await tester.pumpWidget(pantallaCon(HoyDePrueba(() async => [])));
    await tester.pumpAndSettle();

    expect(find.text('No tienes clientes para hoy.'), findsOne);
    expect(find.text('Ver todos los clientes'), findsOne);
  });
}
