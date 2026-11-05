import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/productos_interes_repository_falso.dart';
import 'package:kusdy/features/productos/presentation/productos_interes_providers.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/domain/datos_cliente.dart';
import 'package:kusdy/features/clientes/presentation/cliente_form_screen.dart';

Future<List<DatosCliente>> abrir(
  WidgetTester tester, {
  bool editar = false,
  Object? error,
}) async {
  final guardados = <DatosCliente>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productosInteresRepositoryProvider.overrideWithValue(
          ProductosInteresRepositoryFalso(),
        ),
      ],
      child: MaterialApp(
        home: ClienteFormScreen(
          cliente: editar ? clientesDeEjemplo().first : null,
          alGuardar: (datos) async {
            if (error != null) throw error;
            guardados.add(datos);
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return guardados;
}

Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

void main() {
  testWidgets('no guarda sin nombre ni teléfono', (tester) async {
    final guardados = await abrir(tester);

    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Escribe el nombre del cliente.'), findsOne);
    expect(find.text('Escribe el teléfono.'), findsOne);
    expect(guardados, isEmpty);
  });

  testWidgets('crear: guarda los datos y la primera llamada', (tester) async {
    final guardados = await abrir(tester);

    await tester.enterText(campo('Nombre *'), 'Lucía Ramírez');
    await tester.enterText(campo('Teléfono *'), '44559012');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(guardados, hasLength(1));
    expect(guardados.single.telefono, '4455 9012');
    expect(guardados.single.primeraLlamada, isNotNull);
    expect(guardados.single.productoInteresId, isNull);
  });

  testWidgets('crear: el producto de interés es opcional', (tester) async {
    final guardados = await abrir(tester);

    await tester.enterText(campo('Nombre *'), 'Lucía Ramírez');
    await tester.enterText(campo('Teléfono *'), '44559012');
    final selector = find.byKey(const Key('producto-interes'));
    await tester.ensureVisible(selector);
    await tester.pumpAndSettle();
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calentador solar 300 L').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(guardados.single.productoInteresId, 'p300');
  });

  testWidgets('editar: llega lleno y no agenda otra llamada', (tester) async {
    final guardados = await abrir(tester, editar: true);

    expect(find.text('Editar cliente'), findsOne);
    expect(find.text('María López'), findsOne);
    expect(find.byKey(const Key('primera-llamada')), findsNothing);

    await tester.enterText(campo('Nombre *'), 'María López de Paz');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(guardados.single.nombre, 'María López de Paz');
    expect(guardados.single.primeraLlamada, isNull);
  });

  testWidgets('si falla, muestra el mensaje y deja intentar de nuevo', (
    tester,
  ) async {
    await abrir(
      tester,
      error: const ClienteException(
        'Tu puesto no permite cambiar este cliente.',
      ),
    );

    await tester.enterText(campo('Nombre *'), 'Lucía Ramírez');
    await tester.enterText(campo('Teléfono *'), '44559012');
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Tu puesto no permite cambiar este cliente.'), findsOne);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
