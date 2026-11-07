import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/productos_interes_repository_falso.dart';
import 'package:kusdy/features/productos/presentation/productos_interes_providers.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/data/comentarios_repository_falso.dart';
import 'package:kusdy/features/clientes/presentation/cliente_detalle_screen.dart';
import 'package:kusdy/features/clientes/presentation/clientes_providers.dart';
import 'package:kusdy/features/clientes/presentation/clientes_screen.dart';

Widget app(
  Widget pantalla, {
  ClientesRepositoryFalso? clientes,
  ComentariosRepositoryFalso? comentarios,
}) {
  return ProviderScope(
    overrides: [
      clientesRepositoryProvider.overrideWithValue(
        clientes ?? ClientesRepositoryFalso(demora: Duration.zero),
      ),
      productosInteresRepositoryProvider.overrideWithValue(
        ProductosInteresRepositoryFalso(),
      ),
      comentariosRepositoryProvider.overrideWithValue(
        comentarios ?? ComentariosRepositoryFalso(demora: Duration.zero),
      ),
    ],
    child: MaterialApp(home: pantalla),
  );
}

void main() {
  testWidgets('muestra el último comentario y oculta los demás', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ClienteDetalleScreen(clienteId: '1')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'María López'), findsOne);
    expect(find.text('Pidió la cotización por WhatsApp.'), findsOne);
    expect(find.text('Quiere el de 200 L, espera la quincena.'), findsNothing);

    // Los datos del cliente ocupan más alto: los comentarios quedan abajo.
    await tester.ensureVisible(find.text('Ver todos (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todos (2)'));
    await tester.pump();
    expect(find.text('Quiere el de 200 L, espera la quincena.'), findsOne);
  });

  testWidgets('agregar un comentario lo pone arriba', (tester) async {
    await tester.pumpWidget(app(const ClienteDetalleScreen(clienteId: '1')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('nuevo-comentario')),
      'Ya pagó el anticipo',
    );
    await tester.ensureVisible(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('Ya pagó el anticipo'), findsOne);
    expect(find.text('Pidió la cotización por WhatsApp.'), findsNothing);
  });

  testWidgets('sin comentarios y con aviso de llamadas sin respuesta', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ClienteDetalleScreen(clienteId: '3')));
    await tester.pumpAndSettle();

    expect(find.text('Sin comentarios todavía.'), findsOne);
    expect(find.text('Van 3 llamadas sin respuesta.'), findsOne);
  });

  testWidgets('error al cargar comentarios: Reintentar', (tester) async {
    await tester.pumpWidget(
      app(
        const ClienteDetalleScreen(clienteId: '1'),
        comentarios: ComentariosRepositoryFalso(
          demora: Duration.zero,
          falla: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar los comentarios.'), findsOne);
    expect(find.text('Reintentar'), findsOne);
  });

  testWidgets('desde la lista: + crea un cliente y aparece', (tester) async {
    await tester.pumpWidget(app(const ClientesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuevo'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre *'),
      'Lucía Ramírez',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teléfono *'),
      '44559012',
    );
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Lucía Ramírez'), findsOne);
  });

  testWidgets('desde la lista: tocar un cliente abre su detalle', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ClientesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('José Pérez'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'José Pérez'), findsOne);
    expect(find.text('Llamar'), findsOne);
  });
}
