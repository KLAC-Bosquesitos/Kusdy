import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/categorias_repository_provider.dart';
import '../domain/categoria_producto.dart';

// La lista de categorías. Después de crear, editar, archivar o borrar, la
// pantalla hace ref.invalidate(categoriasProvider): se vuelve a consultar la
// base y se ve lo que de verdad quedó guardado (no se agrega a mano).
final categoriasProvider = FutureProvider<List<CategoriaProducto>>(
  (ref) => ref.watch(categoriasRepositoryProvider).obtenerTodas(),
  // Riverpod 3 reintenta solo cuando hay error, y eso escondería el estado
  // de error. El usuario decide cuándo reintentar.
  retry: (_, _) => null,
);
