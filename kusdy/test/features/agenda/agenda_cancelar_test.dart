import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/core/utils/fechas.dart';
import 'package:kusdy/features/agenda/data/agenda_repository_falso.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/agenda/domain/filtro_agenda.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/agenda/presentation/agenda_screen.dart';

Widget pantallaCon(AgendaRepositoryFalso repositorio) {
  return ProviderScope(
    overrides: [agendaRepositoryProvider.overrideWithValue(repositorio)],
    child: const MaterialApp(home: AgendaScreen()),
  );
}

// Desliza la tarjeta hacia la izquierda, como con el dedo.
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

// Pregunta directo al repositorio qué quedó guardado hoy. runAsync usa el
// reloj real: con el reloj de la prueba, el Future.delayed nunca terminaría.
Future<List<ActividadAgenda>> consultarBase(
  WidgetTester tester,
  AgendaRepositoryFalso repositorio,
) async {
  final hoy = FiltroAgenda(dia: soloDia(DateTime.now()));
  final actividades = await tester.runAsync(
    () => repositorio.obtenerActividades(hoy),
  );
  return actividades!;
}

void main() {
  testWidgets('deslizar cancela en la base y Deshacer la regresa idéntica', (
    tester,
  ) async {
    final repositorio = AgendaRepositoryFalso(demora: Duration.zero);
    await tester.pumpWidget(pantallaCon(repositorio));
    await tester.pumpAndSettle();
    expect(find.text('Hotel Los Altos'), findsOne);

    await deslizar(tester, 'a2');

    expect(find.text('Hotel Los Altos'), findsNothing);
    expect(find.text('Se canceló: Visita con Hotel Los Altos.'), findsOne);
    // Se canceló en la base, no solo en la pantalla.
    final enLaBase = await consultarBase(tester, repositorio);
    expect(enLaBase.map((a) => a.id), isNot(contains('a2')));

    await tester.tap(find.text('Deshacer'));
    await dejarPasar(tester);

    // Vuelve la misma actividad: mismo id, mismos datos y en su hora.
    expect(find.byKey(const ValueKey('a2')), findsOne);
    expect(find.text('11:30'), findsOne);
    expect(
      find.text('Visita · Visita técnica para medir el techo\n7761 2030'),
      findsOne,
    );
    final restauradas = await consultarBase(tester, repositorio);
    expect(restauradas.map((a) => a.id), contains('a2'));
  });

  testWidgets('si la base falla al cancelar, la fila vuelve', (tester) async {
    final repositorio = AgendaRepositoryFalso(
      modo: ModoAgenda.fallaBorrar,
      demora: Duration.zero,
    );
    await tester.pumpWidget(pantallaCon(repositorio));
    await tester.pumpAndSettle();

    await deslizar(tester, 'a2');

    expect(find.text('Hotel Los Altos'), findsOne);
    expect(find.textContaining('No se pudo cancelar'), findsOne);
    expect(find.text('Deshacer'), findsNothing);
  });
}
