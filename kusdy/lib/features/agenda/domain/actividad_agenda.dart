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

// Una actividad en la Agenda del día: qué hay que hacer, con quién y a qué
// hora. Modelo mínimo; cuando se conecte Supabase saldrá de la función
// agenda(dia, vendedor).
class ActividadAgenda {
  const ActividadAgenda({
    required this.id,
    required this.cliente,
    required this.telefono,
    required this.tipo,
    required this.programadaPara,
    required this.descripcion,
    this.estado = EstadoActividad.pendiente,
  });

  final String id;
  final String cliente;
  final String telefono;
  final TipoActividad tipo;
  final DateTime programadaPara;
  final String descripcion;
  final EstadoActividad estado;
}
