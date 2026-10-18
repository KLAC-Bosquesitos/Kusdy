import 'pendiente_hoy.dart';

// Contrato que conoce la pantalla Inicio. Hoy lo cumple un repositorio falso.
abstract class HoyRepository {
  Future<List<PendienteHoy>> obtenerPendientesDeHoy();
}
