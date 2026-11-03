import '../domain/comentario.dart';
import '../domain/comentarios_repository.dart';

// Comentarios en memoria para pruebas y para trabajar sin red.
class ComentariosRepositoryFalso implements ComentariosRepository {
  ComentariosRepositoryFalso({
    List<Comentario>? comentarios,
    this.demora = const Duration(milliseconds: 600),
    this.falla = false,
  }) : _comentarios = [...(comentarios ?? comentariosDeEjemplo())];

  final Duration demora;
  final bool falla;
  final List<Comentario> _comentarios;

  @override
  Future<List<Comentario>> obtenerComentarios(String clienteId) async {
    await Future.delayed(demora);
    if (falla) throw Exception('Sin conexión (simulada)');
    return _comentarios.where((c) => c.clienteId == clienteId).toList()
      ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
  }

  @override
  Future<void> agregarComentario(String clienteId, String texto) async {
    await Future.delayed(demora);
    if (falla) throw Exception('Sin conexión (simulada)');
    _comentarios.add(
      Comentario(
        id: 'c${_comentarios.length + 1}',
        clienteId: clienteId,
        autor: 'Yo',
        texto: texto.trim(),
        creadoEn: DateTime.now(),
      ),
    );
  }
}

List<Comentario> comentariosDeEjemplo([DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  return [
    Comentario(
      id: 'c1',
      clienteId: '1',
      autor: 'Fredy',
      texto: 'Quiere el de 200 L, espera la quincena.',
      creadoEn: h.subtract(const Duration(days: 6)),
    ),
    Comentario(
      id: 'c2',
      clienteId: '1',
      autor: 'Fredy',
      texto: 'Pidió la cotización por WhatsApp.',
      creadoEn: h.subtract(const Duration(days: 1)),
    ),
  ];
}
