import 'actividad_agenda.dart';
import 'filtro_agenda.dart';

// Contrato que conoce la pantalla Agenda. Hoy lo cumple un repositorio falso.
abstract class AgendaRepository {
  // Las actividades del día del filtro que no están canceladas, por hora.
  Future<List<ActividadAgenda>> obtenerActividades(FiltroAgenda filtro);

  // "Borrar" en la Agenda es cancelar: actividades.estado = 'cancelada'.
  // El registro no se pierde, queda en el historial del cliente.
  Future<void> cancelarActividad(String id);

  // Deshacer: vuelve a 'pendiente'. Es el mismo registro, con el mismo id.
  Future<void> reactivarActividad(String id);
}
