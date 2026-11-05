import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/comentario.dart';
import '../domain/comentarios_repository.dart';
import '../domain/datos_cliente.dart';
import 'clientes_repository_supabase.dart' show sinConexion;

class ComentariosRepositorySupabase implements ComentariosRepository {
  ComentariosRepositorySupabase(this._db);

  final SupabaseClient _db;

  @override
  Future<List<Comentario>> obtenerComentarios(String clienteId) async {
    final filas = await _db
        .from('comentarios')
        .select(
          'id, cliente_id, texto, creado_en, editado_en, autor:perfiles(nombre)',
        )
        .eq('cliente_id', clienteId)
        .order('creado_en', ascending: false);
    return [for (final f in filas) comentarioDesdeFila(f)];
  }

  @override
  Future<void> agregarComentario(String clienteId, String texto) async {
    try {
      await _db.from('comentarios').insert({
        'cliente_id': clienteId,
        'autor_id': _db.auth.currentUser!.id,
        'texto': texto.trim(),
      });
    } on PostgrestException {
      throw const ClienteException(sinConexion);
    }
  }
}

Comentario comentarioDesdeFila(Map<String, dynamic> f) {
  final autor = f['autor'] as Map<String, dynamic>?;
  return Comentario(
    id: f['id'] as String,
    clienteId: f['cliente_id'] as String,
    // RLS puede ocultar el perfil del autor.
    autor: autor?['nombre'] as String? ?? 'Otro usuario',
    texto: f['texto'] as String,
    creadoEn: DateTime.parse(f['creado_en'] as String).toLocal(),
    editado: f['editado_en'] != null,
  );
}
