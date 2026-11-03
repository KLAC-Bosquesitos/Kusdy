import 'actividad_agenda.dart';
import 'filtro_agenda.dart';
import 'resultado_llamada.dart';

// Contrato de actividades que usan Hoy, Agenda y "¿Qué pasó?".
abstract class ActividadesRepository {
  // Pendientes de hoy y de días anteriores, por fecha.
  Future<List<ActividadAgenda>> pendientesDeHoy();

  // Las del día del filtro que no están canceladas, por hora.
  Future<List<ActividadAgenda>> obtenerActividades(FiltroAgenda filtro);

  // "Borrar" es cancelar: el registro queda en el historial.
  Future<void> cancelarActividad(String id);

  Future<void> reactivarActividad(String id);

  // Cierra la actividad con su resultado y crea la siguiente, si hay.
  Future<void> registrarResultado(RegistroLlamada registro);

  Future<void> reagendar(String id, DateTime nuevaFecha);
}

// Error con un mensaje que se puede mostrar tal cual.
class ActividadException implements Exception {
  const ActividadException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
