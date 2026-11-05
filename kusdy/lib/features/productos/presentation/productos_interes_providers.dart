import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/productos_interes_repository_supabase.dart';
import '../domain/producto_interes.dart';

final productosInteresRepositoryProvider = Provider<ProductosInteresRepository>(
  (ref) {
    return ProductosInteresRepositorySupabase(Supabase.instance.client);
  },
);

final productosInteresProvider = FutureProvider<List<ProductoInteres>>(
  (ref) => ref.watch(productosInteresRepositoryProvider).obtenerActivos(),
  retry: (_, _) => null,
);
