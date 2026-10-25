import 'actividad_agenda.dart';

// Qué día y qué tipo de actividades se ven en la Agenda.
//
// Es inmutable: no se cambia un campo, se crea un filtro nuevo. Así Riverpod
// puede comparar el filtro viejo con el nuevo (==) y, si es distinto, repetir
// la consulta sola.
class FiltroAgenda {
  const FiltroAgenda({required this.dia, this.tipo});

  // El día a las 00:00 (la Agenda es solo vista por día, punto 6 de la retro).
  final DateTime dia;

  // null = todos los tipos.
  final TipoActividad? tipo;

  @override
  bool operator ==(Object other) =>
      other is FiltroAgenda && other.dia == dia && other.tipo == tipo;

  @override
  int get hashCode => Object.hash(dia, tipo);
}
