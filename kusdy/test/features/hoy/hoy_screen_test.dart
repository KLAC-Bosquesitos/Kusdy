import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/app/pestana.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_falso.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/hoy/presentation/hoy_screen.dart';

// Responde lo que cada prueba quiera en pendientesDeHoy.
class HoyDePrueba extends ActividadesRepositoryFalso {
  HoyDePrueba(this.respuesta) : super(demora: Duration.zero);

  Future<List<ActividadAgenda>> Function() respuesta;

  @override
  Future<List<ActividadAgenda>> pendientesDeHoy() => respuesta();
}

Widget pantallaCon(HoyDePrueba repositorio) {
  return ProviderScope(
    overrides: [actividadesRepositoryProvider.overrideWithValue(repositorio)],
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

    repositorio.respuesta = () async => actividadesDeEjemplo();
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('María López'), findsWidgets);
  });

  testWidgets('cargando -> datos', (tester) async {
    final lectura = Completer<List<ActividadAgenda>>();
    await tester.pumpWidget(pantallaCon(HoyDePrueba(() => lectura.future)));

    expect(find.text('Revisando tu día…'), findsOne);

    lectura.complete(actividadesDeEjemplo());
    await tester.pumpAndSettle();

    expect(find.text('Hotel Los Altos'), findsOne);
  });

  testWidgets('vacío: ofrece ver todos los clientes', (tester) async {
    await tester.pumpWidget(pantallaCon(HoyDePrueba(() async => [])));
    await tester.pumpAndSettle();

    expect(find.text('No tienes clientes para hoy.'), findsOne);
    expect(find.text('Ver todos los clientes'), findsOne);

    final contenedor = ProviderScope.containerOf(
      tester.element(find.byType(HoyScreen)),
    );
    await tester.tap(find.text('Ver todos los clientes'));
    await tester.pump();
    expect(contenedor.read(pestanaProvider), Pestana.clientes);
  });
}
