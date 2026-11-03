import 'comentario.dart';

abstract class ComentariosRepository {
  // Del más nuevo al más viejo.
  Future<List<Comentario>> obtenerComentarios(String clienteId);

  Future<void> agregarComentario(String clienteId, String texto);
}
