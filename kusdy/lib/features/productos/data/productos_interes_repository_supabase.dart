import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/producto_interes.dart';

class ProductosInteresRepositorySupabase implements ProductosInteresRepository {
  ProductosInteresRepositorySupabase(this._db);

  final SupabaseClient _db;

  @override
  Future<List<ProductoInteres>> obtenerActivos() async {
    final filas = await _db
        .from('productos')
        .select('id, nombre')
        .eq('activo', true)
        .eq('tipo', 'producto')
        .order('nombre');
    return [
      for (final f in filas)
        ProductoInteres(id: f['id'] as String, nombre: f['nombre'] as String),
    ];
  }
}
