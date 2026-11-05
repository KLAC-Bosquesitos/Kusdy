import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/productos_interes_repository_falso.dart';
import 'package:kusdy/features/productos/presentation/productos_interes_providers.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_falso.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/hoy/presentation/hoy_screen.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/presentation/clientes_providers.dart';
import 'package:kusdy/features/clientes/presentation/clientes_screen.dart';

import '../../helpers/repositorios_falsos.dart';

void main() {
  testWidgets('tocar el nombre en Hoy abre el detalle del cliente', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: repositoriosFalsos(),
        child: const MaterialApp(home: HoyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('María López'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'María López'), findsOne);
    expect(find.text('Comentarios'), findsOne);
  });

  testWidgets('crear un cliente vuelve a pedir los pendientes de Hoy', (
    tester,
  ) async {
    final actividades = ContadorDeLecturas();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientesRepositoryProvider.overrideWithValue(
            ClientesRepositoryFalso(demora: Duration.zero),
          ),
          actividadesRepositoryProvider.overrideWithValue(actividades),
          productosInteresRepositoryProvider.overrideWithValue(
            ProductosInteresRepositoryFalso(),
          ),
        ],
        child: const MaterialApp(
          home: Column(
            children: [
              Expanded(child: ClientesScreen()),
              Expanded(child: HoyScreen()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(actividades.lecturasDeHoy, 1);

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

    expect(actividades.lecturasDeHoy, 2);
  });
}

class ContadorDeLecturas extends ActividadesRepositoryFalso {
  ContadorDeLecturas() : super(demora: Duration.zero);

  var lecturasDeHoy = 0;

  @override
  Future<List<ActividadAgenda>> pendientesDeHoy() {
    lecturasDeHoy++;
    return super.pendientesDeHoy();
  }
}
