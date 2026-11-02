import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/categoria_producto.dart';
import '../domain/categorias_repository.dart';

// Categorías en la tabla categorias_producto de Supabase (migración 4).
// La seguridad (RLS) decide quién puede escribir: jefe, supervisor y gerente.
class CategoriasRepositorySupabase implements CategoriasRepository {
  CategoriasRepositorySupabase(this._db);

  final SupabaseClient _db;

  @override
  Future<List<CategoriaProducto>> obtenerTodas() async {
    // productos(count) le pide a la base que cuente los productos de cada
    // categoría en la misma consulta (sigue la llave productos.categoria_id).
    final filas = await _db
        .from('categorias_producto')
        .select('id, nombre, archivada, productos(count)')
        .order('archivada')
        .order('nombre');
    return [
      for (final f in filas)
        CategoriaProducto(
          id: f['id'] as String,
          nombre: f['nombre'] as String,
          archivada: f['archivada'] as bool,
          productos: (f['productos'] as List).first['count'] as int,
        ),
    ];
  }

  @override
  Future<void> guardar({String? id, required String nombre}) async {
    final limpio = nombreCategoriaValido(nombre);
    try {
      if (id == null) {
        await _db.from('categorias_producto').insert({'nombre': limpio});
      } else {
        // UPDATE de la misma fila: el id no cambia.
        final cambiadas = await _db
            .from('categorias_producto')
            .update({'nombre': limpio})
            .eq('id', id)
            .select('id');
        if (cambiadas.isEmpty) throw const CategoriaException(sinPermiso);
      }
    } on PostgrestException catch (e) {
      throw traducirErrorCategoria(e, nombre: limpio);
    }
  }

  @override
  Future<void> archivar(String id, {required bool archivada}) async {
    try {
      final cambiadas = await _db
          .from('categorias_producto')
          .update({'archivada': archivada})
          .eq('id', id)
          .select('id');
      if (cambiadas.isEmpty) throw const CategoriaException(sinPermiso);
    } on PostgrestException catch (e) {
      throw traducirErrorCategoria(e);
    }
  }

  @override
  Future<void> eliminar(String id) async {
    // Primero se cuenta, para dar el mensaje con el número de productos.
    // La llave foránea (ON DELETE RESTRICT) es la última defensa por si
    // alguien agrega un producto justo en medio.
    final productos = await _db
        .from('productos')
        .count(CountOption.exact)
        .eq('categoria_id', id);
    if (productos > 0) throw CategoriaException.enUso(productos);
    try {
      final borradas = await _db
          .from('categorias_producto')
          .delete()
          .eq('id', id)
          .select('id');
      if (borradas.isEmpty) throw const CategoriaException(sinPermiso);
    } on PostgrestException catch (e) {
      throw traducirErrorCategoria(e);
    }
  }
}

// Con RLS, si tu rol no puede escribir, la base no da error: simplemente no
// cambia ninguna fila. Por eso se pide .select('id') y se revisa si volvió vacío.
const sinPermiso = 'Tu puesto no permite cambiar categorías.';

// Convierte un error de Postgres en un mensaje para personas. Los códigos son
// estándar de Postgres: https://www.postgresql.org/docs/current/errcodes-appendix.html
CategoriaException traducirErrorCategoria(
  PostgrestException e, {
  String? nombre,
}) {
  return switch (e.code) {
    // unique_violation: el índice único de lower(nombre).
    '23505' => CategoriaException.repetida(nombre ?? ''),
    // foreign_key_violation: todavía hay productos con esta categoría.
    '23503' => const CategoriaException(
      'Tiene productos. Archívala para dejar de verla.',
    ),
    // insufficient_privilege: la política de RLS no dejó crear.
    '42501' => const CategoriaException(sinPermiso),
    _ => const CategoriaException(
      'No pudimos guardar el cambio. Revisa tu conexión e intenta de nuevo.',
    ),
  };
}
