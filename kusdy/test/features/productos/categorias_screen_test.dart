import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/categorias_repository_memoria.dart';
import 'package:kusdy/features/productos/data/categorias_repository_provider.dart';
import 'package:kusdy/features/productos/domain/categoria_producto.dart';
import 'package:kusdy/features/productos/domain/categorias_repository.dart';
import 'package:kusdy/features/productos/presentation/categorias_screen.dart';

// Falla la primera vez que se lee, como si no hubiera señal.
class _RepoQueFallaUnaVez extends CategoriasRepositoryMemoria {
  _RepoQueFallaUnaVez() : super(demora: Duration.zero);
  var _lecturas = 0;

  @override
  Future<List<CategoriaProducto>> obtenerTodas() {
    if (_lecturas++ == 0) throw Exception('Sin conexión (simulada)');
    return super.obtenerTodas();
  }
}

Widget pantallaCon(CategoriasRepository repo) => ProviderScope(
  overrides: [categoriasRepositoryProvider.overrideWithValue(repo)],
  child: const MaterialApp(home: CategoriasScreen()),
);

void main() {
  testWidgets('cargando y luego datos', (tester) async {
    await tester.pumpWidget(
      pantallaCon(
        CategoriasRepositoryMemoria(demora: const Duration(seconds: 1)),
      ),
    );
    expect(find.text('Cargando categorías…'), findsOne);

    await tester.pumpAndSettle();
    expect(find.text('Calentador solar por gravedad'), findsOne);
    expect(find.text('5 productos'), findsNWidgets(2));
  });

  testWidgets('error con Reintentar y luego datos', (tester) async {
    await tester.pumpWidget(pantallaCon(_RepoQueFallaUnaVez()));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pudimos cargar las categorías'), findsOne);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Servicios'), findsOne);
  });

  testWidgets('vacío: invita a crear la primera', (tester) async {
    await tester.pumpWidget(
      pantallaCon(
        CategoriasRepositoryMemoria(categorias: [], demora: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay categorías.'), findsOne);
    await tester.tap(find.text('Nueva categoría'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Nueva categoría'), findsOne);
  });
}
