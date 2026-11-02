import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/categorias_repository_memoria.dart';
import 'package:kusdy/features/productos/data/categorias_repository_provider.dart';
import 'package:kusdy/features/productos/domain/categoria_producto.dart';
import 'package:kusdy/features/productos/presentation/categorias_screen.dart';

// La pantalla con el repositorio en memoria (sin internet).
Future<CategoriasRepositoryMemoria> abrir(WidgetTester tester) async {
  final repo = CategoriasRepositoryMemoria(demora: Duration.zero);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [categoriasRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: CategoriasScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

// Pregunta directo al repositorio qué quedó guardado.
Future<List<CategoriaProducto>> enLaBase(
  WidgetTester tester,
  CategoriasRepositoryMemoria repo,
) async => (await tester.runAsync(repo.obtenerTodas))!;

// Escribe y redibuja: el botón se habilita hasta que hay texto.
Future<void> escribirNombre(WidgetTester tester, String nombre) async {
  await tester.enterText(find.widgetWithText(TextField, 'Nombre'), nombre);
  await tester.pump();
}

Future<void> tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('crear: aparece en la lista sin recargar a mano', (tester) async {
    final repo = await abrir(tester);

    await tocar(tester, 'Nueva');
    expect(find.widgetWithText(AppBar, 'Nueva categoría'), findsOne);
    await escribirNombre(tester, 'Paneles solares');
    await tocar(tester, 'Crear');

    expect(find.widgetWithText(AppBar, 'Categorías de productos'), findsOne);
    expect(find.text('Paneles solares'), findsOne);
    expect(find.text('Categoría creada.'), findsOne);
    final guardadas = await enLaBase(tester, repo);
    expect(guardadas.map((c) => c.nombre), contains('Paneles solares'));
  });

  testWidgets(
    'tocar abre el formulario lleno y "Guardar cambios" actualiza sin cambiar el id',
    (tester) async {
      final repo = await abrir(tester);

      await tocar(tester, 'Servicios');

      // El formulario abre lleno, en modo edición.
      expect(find.widgetWithText(AppBar, 'Editar categoría'), findsOne);
      expect(find.widgetWithText(TextField, 'Servicios'), findsOne);
      expect(find.text('Guardar cambios'), findsOne);

      await escribirNombre(tester, 'Instalaciones');
      await tocar(tester, 'Guardar cambios');

      expect(find.text('Instalaciones'), findsOne);
      expect(find.text('Servicios'), findsNothing);
      expect(find.text('Cambios guardados.'), findsOne);
      // Es la MISMA fila: conserva su id (c3) y su producto.
      expect(find.byKey(const ValueKey('c3')), findsOne);
      final c3 = (await enLaBase(
        tester,
        repo,
      )).singleWhere((c) => c.id == 'c3');
      expect(c3.nombre, 'Instalaciones');
      expect(c3.productos, 1);
    },
  );

  testWidgets('borrar una categoría en uso: mensaje claro y sigue ahí', (
    tester,
  ) async {
    final repo = await abrir(tester);

    await tocar(tester, 'Servicios');
    await tocar(tester, 'Eliminar');
    expect(find.text('¿Eliminar categoría?'), findsOne);
    await tocar(tester, 'Eliminar'); // el del diálogo

    expect(
      find.text('Tiene 1 producto. Archívala para dejar de verla.'),
      findsOne,
    );
    expect(find.text('Archivar'), findsOne);
    final guardadas = await enLaBase(tester, repo);
    expect(guardadas.map((c) => c.id), contains('c3'));

    // La otra salida: archivarla. Pasa a la sección "Archivadas".
    await tocar(tester, 'Archivar');
    expect(find.text('Archivadas'), findsOne);
    expect(find.text('1 producto · archivada'), findsOne);
  });

  testWidgets('nombre repetido: mensaje humano, no un error técnico', (
    tester,
  ) async {
    await abrir(tester);

    await tocar(tester, 'Nueva');
    // Mismo nombre con otras mayúsculas y espacios: también es repetido.
    await escribirNombre(tester, '  servicios ');
    await tocar(tester, 'Crear');

    expect(find.text('Ya existe la categoría "servicios".'), findsOne);
    // El formulario sigue abierto para corregir.
    expect(find.widgetWithText(AppBar, 'Nueva categoría'), findsOne);
  });

  testWidgets('una categoría sin productos sí se elimina', (tester) async {
    final repo = await abrir(tester);
    await tocar(tester, 'Nueva');
    await escribirNombre(tester, 'Bombas de agua');
    await tocar(tester, 'Crear');

    await tocar(tester, 'Bombas de agua');
    await tocar(tester, 'Eliminar');
    await tocar(tester, 'Eliminar');

    expect(find.text('Bombas de agua'), findsNothing);
    expect(find.text('Se eliminó "Bombas de agua".'), findsOne);
    final guardadas = await enLaBase(tester, repo);
    expect(guardadas.map((c) => c.nombre), isNot(contains('Bombas de agua')));
  });
}
