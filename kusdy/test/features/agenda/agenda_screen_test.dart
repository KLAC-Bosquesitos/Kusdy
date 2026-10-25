import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/agenda/data/agenda_repository_falso.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/agenda/presentation/agenda_screen.dart';

Widget pantallaCon(AgendaRepositoryFalso repositorio) {
  return ProviderScope(
    overrides: [agendaRepositoryProvider.overrideWithValue(repositorio)],
    child: const MaterialApp(home: AgendaScreen()),
  );
}

// Los estados de la S14 siguen ahí: cargando, error con Reintentar y vacío.
void main() {
  testWidgets('cargando -> datos de hoy en orden de hora', (tester) async {
    await tester.pumpWidget(pantallaCon(AgendaRepositoryFalso()));

    expect(find.text('Cargando tu agenda…'), findsOne);

    await tester.pumpAndSettle();
    expect(find.textContaining('Hoy ·'), findsOne);
    expect(find.text('09:00'), findsOne);
    expect(find.text('María López'), findsOne);
  });

  testWidgets('error -> Reintentar -> datos', (tester) async {
    await tester.pumpWidget(
      pantallaCon(
        AgendaRepositoryFalso(modo: ModoAgenda.error, demora: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No pudimos cargar tu agenda'), findsOne);
    expect(find.textContaining('Sin conexión'), findsNothing);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Hotel Los Altos'), findsOne);
  });

  testWidgets('vacío: ofrece ver el día siguiente', (tester) async {
    await tester.pumpWidget(
      pantallaCon(
        AgendaRepositoryFalso(actividades: [], demora: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tienes actividades este día.'), findsOne);
    await tester.tap(find.text('Ver el día siguiente'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mañana ·'), findsOne);
  });
}
