// Un cliente al que hay que atender hoy (boceto 1, "Clientes para hoy").
// Modelo mínimo: cuando exista la base de datos saldrá de las actividades.
class PendienteHoy {
  const PendienteHoy({
    required this.id,
    required this.cliente,
    required this.telefono,
    required this.motivo,
    required this.hora,
  });

  final String id;
  final String cliente;
  final String telefono;
  // Qué hay que hacer: "Llamar para cotización", "Confirmar visita"...
  final String motivo;
  // Hora en texto ("10:30") mientras no hay fechas reales.
  final String hora;
}
