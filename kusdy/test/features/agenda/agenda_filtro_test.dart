import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_falso.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/agenda/presentation/agenda_screen.dart';

// El repositorio falso de la app, sin esperas. Los datos de ejemplo tienen
// 4 actividades hoy (2 llamadas, 1 visita, 1 instalación) y 2 mañana.
Future<void> abrirAgenda(WidgetTester tester) async {
  // Pantalla del tamaño de un celular, para que quepan las 4 tarjetas.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        actividadesRepositoryProvider.overrideWithValue(
          ActividadesRepositoryFalso(demora: Duration.zero),
        ),
      ],
      // En español, como la app, para que el calendario use sus textos.
      child: const MaterialApp(
        locale: Locale('es'),
        supportedLocales: [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: AgendaScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> elegirTipo(WidgetTester tester, String texto) async {
  await tester.tap(find.byKey(const Key('filtro-tipo')));
  await tester.pumpAndSettle();
  // El menú abierto repite el texto elegido: se toca el último.
  await tester.tap(find.text(texto).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('al elegir un tipo, la lista cambia sola', (tester) async {
    await abrirAgenda(tester);
    expect(find.byType(Dismissible), findsNWidgets(4));

    await elegirTipo(tester, 'Llamadas');
    expect(find.byType(Dismissible), findsNWidgets(2));
    expect(find.text('María López'), findsOne);
    expect(find.text('Carlos Méndez'), findsOne);
    expect(find.text('Hotel Los Altos'), findsNothing);

    await elegirTipo(tester, 'Todos los tipos');
    expect(find.byType(Dismissible), findsNWidgets(4));
  });

  testWidgets('al cambiar de día, la lista cambia sola', (tester) async {
    await abrirAgenda(tester);

    await tester.tap(find.byTooltip('Día siguiente'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mañana ·'), findsOne);
    expect(find.text('Ana Gómez'), findsOne);
    expect(find.byType(Dismissible), findsNWidgets(2));

    await tester.tap(find.text('Volver a hoy'));
    await tester.pumpAndSettle();
    expect(find.byType(Dismissible), findsNWidgets(4));
  });

  testWidgets('tipo sin resultados: vacío según el filtro', (tester) async {
    await abrirAgenda(tester);

    await elegirTipo(tester, 'Citas');
    expect(find.text('No tienes citas este día.'), findsOne);

    await tester.tap(find.text('Ver todos los tipos'));
    await tester.pumpAndSettle();
    expect(find.byType(Dismissible), findsNWidgets(4));
  });

  testWidgets('al elegir una fecha en el calendario, la lista cambia sola', (
    tester,
  ) async {
    await abrirAgenda(tester);

    await tester.tap(find.byTooltip('Elegir fecha'));
    await tester.pumpAndSettle();
    final manana = DateTime.now().add(const Duration(days: 1));
    if (manana.day == 1) {
      await tester.tap(find.byTooltip('Mes siguiente'));
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.descendant(
        of: find.byType(CalendarDatePicker),
        matching: find.text('${manana.day}'),
      ),
    );
    await tester.tap(find.text('Ir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mañana ·'), findsOne);
    expect(find.byType(Dismissible), findsNWidgets(2));
  });

  testWidgets('cancelar el calendario deja el mismo día', (tester) async {
    await abrirAgenda(tester);

    await tester.tap(find.byTooltip('Elegir fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hoy ·'), findsOne);
    expect(find.byType(Dismissible), findsNWidgets(4));
  });
}
