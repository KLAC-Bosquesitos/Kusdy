import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/llamadas/presentation/tarjeta_actividad.dart';

ActividadAgenda actividad({
  String descripcion = '',
  String? notaFija,
  String? ultimoComentario,
}) {
  return ActividadAgenda(
    id: 'a1',
    clienteId: '1',
    cliente: 'María López',
    telefono: '5512 3456',
    tipo: TipoActividad.llamada,
    programadaPara: DateTime.now(),
    descripcion: descripcion,
    notaFija: notaFija,
    ultimoComentario: ultimoComentario,
  );
}

Future<void> mostrar(WidgetTester tester, ActividadAgenda a) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: TarjetaActividad(actividad: a)),
      ),
    ),
  );
}

void main() {
  testWidgets('no muestra el teléfono del cliente', (tester) async {
    await mostrar(tester, actividad());

    expect(find.textContaining('5512 3456'), findsNothing);
    expect(find.text('Llamar'), findsOne);
  });

  testWidgets('la nota fija gana sobre el último comentario', (tester) async {
    await mostrar(
      tester,
      actividad(notaFija: 'Después de las 5', ultimoComentario: 'Espera'),
    );

    expect(find.text('Después de las 5'), findsOne);
    expect(find.text('Espera'), findsNothing);
    expect(find.byIcon(Icons.push_pin_outlined), findsOne);
  });

  testWidgets('sin nota fija muestra el último comentario', (tester) async {
    await mostrar(
      tester,
      actividad(notaFija: '  ', ultimoComentario: 'Espera'),
    );

    expect(find.text('Espera'), findsOne);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOne);
  });

  testWidgets('no repite el comentario que ya es la descripción', (
    tester,
  ) async {
    await mostrar(
      tester,
      actividad(descripcion: 'Espera', ultimoComentario: 'Espera'),
    );

    expect(find.text('Espera'), findsOne);
  });

  testWidgets('sin nota ni comentario no deja rastro', (tester) async {
    await mostrar(tester, actividad());

    expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
  });
}
