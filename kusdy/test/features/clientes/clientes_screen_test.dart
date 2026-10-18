import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/domain/cliente.dart';
import 'package:kusdy/features/clientes/domain/clientes_repository.dart';
import 'package:kusdy/features/clientes/presentation/clientes_providers.dart';
import 'package:kusdy/features/clientes/presentation/clientes_screen.dart';

// Repositorio de prueba: responde lo que cada prueba quiera, sin esperas.
class RepositorioDePrueba implements ClientesRepository {
  RepositorioDePrueba(this.respuesta);

  Future<List<Cliente>> Function() respuesta;

  @override
  Future<List<Cliente>> obtenerClientes() => respuesta();
}

Widget appCon(ClientesRepository repositorio) {
  return ProviderScope(
    // Override: en esta prueba, el provider entrega el repositorio de prueba.
    overrides: [clientesRepositoryProvider.overrideWithValue(repositorio)],
    // Solo la pantalla, no toda la app: si cambia la pantalla de inicio,
    // esta prueba sigue funcionando.
    child: const MaterialApp(home: ClientesScreen()),
  );
}

void main() {
  testWidgets('error: mensaje para personas y botón Reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(
      appCon(RepositorioDePrueba(() async => throw Exception('sin red'))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No pudimos cargar tus clientes'), findsOne);
    expect(find.text('Reintentar'), findsOne);
    // El texto técnico de la excepción nunca llega a la pantalla.
    expect(find.textContaining('sin red'), findsNothing);
  });

  testWidgets('error -> Reintentar -> datos', (tester) async {
    final repositorio = RepositorioDePrueba(
      () async => throw Exception('sin red'),
    );
    await tester.pumpWidget(appCon(repositorio));
    await tester.pumpAndSettle();
    expect(find.text('Reintentar'), findsOne);

    // Vuelve la conexión y el usuario reintenta.
    repositorio.respuesta = () async => clientesDeEjemplo;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('María López'), findsOne);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('cargando -> datos', (tester) async {
    final lectura = Completer<List<Cliente>>();
    await tester.pumpWidget(appCon(RepositorioDePrueba(() => lectura.future)));

    expect(find.byType(CircularProgressIndicator), findsOne);
    expect(find.text('Cargando clientes…'), findsOne);

    lectura.complete(clientesDeEjemplo);
    await tester.pumpAndSettle();

    expect(find.text('María López'), findsOne);
    expect(find.text('5512 3456 · Calentador solar 200 L'), findsOne);
  });

  testWidgets('vacío: invita a agregar el primer cliente', (tester) async {
    await tester.pumpWidget(appCon(RepositorioDePrueba(() async => [])));
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes clientes.'), findsOne);
    await tester.tap(find.text('Agregar cliente'));
    await tester.pump();
    expect(find.text('Muy pronto podrás agregar clientes.'), findsOne);
  });
}
