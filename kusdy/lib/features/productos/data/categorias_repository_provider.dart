import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/categorias_repository.dart';
import 'categorias_repository_memoria.dart';

// Qué repositorio de categorías usa la app. Vive en su propio archivo para
// que el PR de Supabase cambie solo este archivo, sin chocar con el PR de las
// pantallas. Las pruebas lo reemplazan con overrideWithValue.
final categoriasRepositoryProvider = Provider<CategoriasRepository>((ref) {
  return CategoriasRepositoryMemoria();
});
