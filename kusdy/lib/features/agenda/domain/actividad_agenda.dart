// Tipos y estados con los mismos valores que los enums de Postgres
// (tipo_actividad y estado_actividad en supabase/migrations/).
enum TipoActividad {
  llamada('Llamada', 'Llamadas'),
  cita('Cita', 'Citas'),
  visita('Visita', 'Visitas'),
  instalacion('Instalación', 'Instalaciones'),
  seguimiento('Seguimiento', 'Seguimientos');

  const TipoActividad(this.texto, this.plural);

  // Para la pantalla: "Instalación", nunca "instalacion".
  final String texto;
  final String plural;
}

enum EstadoActividad { pendiente, completada, cancelada }

// Una actividad de Hoy o de la Agenda: qué hay que hacer, con quién y cuándo.
class ActividadAgenda {
  const ActividadAgenda({
    required this.id,
    required this.clienteId,
    required this.cliente,
    required this.telefono,
    required this.tipo,
    required this.programadaPara,
    required this.descripcion,
    this.estado = EstadoActividad.pendiente,
    this.intentosSinRespuesta = 0,
    this.notaFija,
    this.ultimoComentario,
  });

  final String id;
  final String clienteId;
  final String cliente;
  final String telefono;
  final TipoActividad tipo;
  final DateTime programadaPara;
  final String descripcion;
  final EstadoActividad estado;

  // Llamadas seguidas sin respuesta del cliente (aviso a partir de 3).
  final int intentosSinRespuesta;

  // Del cliente: lo que conviene tener presente antes de llamarle.
  final String? notaFija;
  final String? ultimoComentario;

  // Pendiente de un día anterior: va en "Se te pasaron".
  bool vencida(DateTime ahora) =>
      estado == EstadoActividad.pendiente &&
      programadaPara.isBefore(DateTime(ahora.year, ahora.month, ahora.day));

  ActividadAgenda copiar({EstadoActividad? estado, DateTime? programadaPara}) {
    return ActividadAgenda(
      id: id,
      clienteId: clienteId,
      cliente: cliente,
      telefono: telefono,
      tipo: tipo,
      programadaPara: programadaPara ?? this.programadaPara,
      descripcion: descripcion,
      estado: estado ?? this.estado,
      intentosSinRespuesta: intentosSinRespuesta,
      notaFija: notaFija,
      ultimoComentario: ultimoComentario,
    );
  }
}
