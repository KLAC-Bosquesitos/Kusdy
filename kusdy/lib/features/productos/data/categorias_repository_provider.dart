import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/categorias_repository.dart';
import 'categorias_repository_supabase.dart';

// Qué repositorio de categorías usa la app: Supabase (migración 4). Vive en
// su propio archivo para no chocar con el PR de las pantallas. Las pruebas
// lo reemplazan con overrideWithValue(CategoriasRepositoryMemoria()).
final categoriasRepositoryProvider = Provider<CategoriasRepository>((ref) {
  return CategoriasRepositorySupabase(Supabase.instance.client);
});
