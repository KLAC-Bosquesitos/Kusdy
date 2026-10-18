import '../domain/hoy_repository.dart';
import '../domain/pendiente_hoy.dart';

// Cómo se comporta el repositorio falso. Se elige al correr la app:
//   flutter run --dart-define=HOY_MODO=lento
enum ModoHoy {
  normal,
  lento,
  // Falla la primera vez y responde bien después: para probar Reintentar.
  error,
  vacio;

  static ModoHoy desdeEntorno() {
    const valor = String.fromEnvironment('HOY_MODO', defaultValue: 'normal');
    return ModoHoy.values.firstWhere(
      (modo) => modo.name == valor,
      orElse: () => ModoHoy.normal,
    );
  }
}

// Datos fijos mientras el diseño de la base de datos está en pausa.
// Future.delayed simula la espera de la red.
class HoyRepositoryFalso implements HoyRepository {
  HoyRepositoryFalso({this.modo = ModoHoy.normal});

  final ModoHoy modo;
  var _llamadas = 0;

  @override
  Future<List<PendienteHoy>> obtenerPendientesDeHoy() async {
    _llamadas++;
    await Future.delayed(
      modo == ModoHoy.lento
          ? const Duration(seconds: 6)
          : const Duration(milliseconds: 1200),
    );

    if (modo == ModoHoy.error && _llamadas == 1) {
      throw Exception('Sin conexión (simulada)');
    }
    if (modo == ModoHoy.vacio) return [];
    return pendientesDeEjemplo;
  }
}

const pendientesDeEjemplo = [
  PendienteHoy(
    id: '1',
    cliente: 'María López',
    telefono: '5512 3456',
    motivo: 'Llamar para enviar cotización',
    hora: '09:00',
  ),
  PendienteHoy(
    id: '2',
    cliente: 'Hotel Los Altos',
    telefono: '7761 2030',
    motivo: 'Confirmar visita técnica',
    hora: '11:30',
  ),
  PendienteHoy(
    id: '3',
    cliente: 'Carlos Méndez',
    telefono: '5874 6655',
    motivo: 'Seguimiento: ¿ya decidió el calentador?',
    hora: '15:00',
  ),
];
