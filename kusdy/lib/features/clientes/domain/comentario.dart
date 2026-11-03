// Comentario sobre un cliente (tabla comentarios). Solo su autor lo edita.
class Comentario {
  const Comentario({
    required this.id,
    required this.clienteId,
    required this.autor,
    required this.texto,
    required this.creadoEn,
    this.editado = false,
  });

  final String id;
  final String clienteId;
  final String autor;
  final String texto;
  final DateTime creadoEn;
  final bool editado;
}
