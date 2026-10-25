import '../../../core/utils/fechas.dart';
import '../domain/actividad_agenda.dart';
import '../domain/agenda_repository.dart';
import '../domain/filtro_agenda.dart';

// Cómo se comporta el repositorio falso. Se elige al correr la app:
//   flutter run --dart-define=AGENDA_MODO=lento
enum ModoAgenda {
  normal,
  lento,
  // Falla la primera vez y responde bien después: para probar Reintentar.
  error,
  vacio,
  // Lee bien, pero cancelar falla: para ver que la fila vuelve.
  fallaBorrar;

  static ModoAgenda desdeEntorno() {
    const valor = String.fromEnvironment('AGENDA_MODO', defaultValue: 'normal');
    return ModoAgenda.values.firstWhere(
      (modo) => modo.name == valor,
      orElse: () => ModoAgenda.normal,
    );
  }
}

// Actividades en memoria mientras no se conecta Supabase. Future.delayed
// simula la espera de la red. Lo cancelado se recuerda mientras la app está
// abierta; al cerrarla vuelven los datos de ejemplo.
class AgendaRepositoryFalso implements AgendaRepository {
  AgendaRepositoryFalso({
    this.modo = ModoAgenda.normal,
    List<ActividadAgenda>? actividades,
    this.demora = const Duration(milliseconds: 1200),
  }) : _actividades = [...(actividades ?? actividadesDeEjemplo())];

  final ModoAgenda modo;
  final Duration demora;
  final List<ActividadAgenda> _actividades;
  var _llamadas = 0;

  @override
  Future<List<ActividadAgenda>> obtenerActividades(FiltroAgenda filtro) async {
    _llamadas++;
    await Future.delayed(
      modo == ModoAgenda.lento ? const Duration(seconds: 6) : demora,
    );

    if (modo == ModoAgenda.error && _llamadas == 1) {
      throw Exception('Sin conexión (simulada)');
    }
    if (modo == ModoAgenda.vacio) return [];

    // Lo que en Supabase hará la consulta.
    final delDia = _actividades.where(
      (a) =>
          a.estado != EstadoActividad.cancelada &&
          mismoDia(a.programadaPara, filtro.dia) &&
          (filtro.tipo == null || a.tipo == filtro.tipo),
    );
    return delDia.toList()
      ..sort((a, b) => a.programadaPara.compareTo(b.programadaPara));
  }

  @override
  Future<void> cancelarActividad(String id) async {
    await Future.delayed(demora ~/ 3);
    if (modo == ModoAgenda.fallaBorrar) {
      throw Exception('Sin conexión (simulada)');
    }
    _cambiarEstado(id, EstadoActividad.cancelada);
  }

  @override
  Future<void> reactivarActividad(String id) async {
    await Future.delayed(demora ~/ 3);
    _cambiarEstado(id, EstadoActividad.pendiente);
  }

  // Se reemplaza la actividad por una copia con otro estado: mismo id y
  // mismos datos, como un UPDATE en la base.
  void _cambiarEstado(String id, EstadoActividad estado) {
    final i = _actividades.indexWhere((a) => a.id == id);
    if (i == -1) return;
    final a = _actividades[i];
    _actividades[i] = ActividadAgenda(
      id: a.id,
      cliente: a.cliente,
      telefono: a.telefono,
      tipo: a.tipo,
      programadaPara: a.programadaPara,
      descripcion: a.descripcion,
      estado: estado,
    );
  }
}

// Fechas relativas a hoy, para que la Agenda de hoy siempre tenga datos.
List<ActividadAgenda> actividadesDeEjemplo([DateTime? hoy]) {
  final h = soloDia(hoy ?? DateTime.now());
  DateTime el(int dias, int hora, int minuto) =>
      DateTime(h.year, h.month, h.day + dias, hora, minuto);

  return [
    ActividadAgenda(
      id: 'a1',
      cliente: 'María López',
      telefono: '5512 3456',
      tipo: TipoActividad.llamada,
      programadaPara: el(0, 9, 0),
      descripcion: 'Enviar cotización del calentador 200 L',
    ),
    ActividadAgenda(
      id: 'a2',
      cliente: 'Hotel Los Altos',
      telefono: '7761 2030',
      tipo: TipoActividad.visita,
      programadaPara: el(0, 11, 30),
      descripcion: 'Visita técnica para medir el techo',
    ),
    ActividadAgenda(
      id: 'a3',
      cliente: 'Carlos Méndez',
      telefono: '5874 6655',
      tipo: TipoActividad.llamada,
      programadaPara: el(0, 15, 0),
      descripcion: '¿Ya decidió el calentador?',
    ),
    ActividadAgenda(
      id: 'a4',
      cliente: 'José Pérez',
      telefono: '4021 7788',
      tipo: TipoActividad.instalacion,
      programadaPara: el(0, 16, 30),
      descripcion: 'Instalación de paneles solares',
    ),
    ActividadAgenda(
      id: 'a5',
      cliente: 'Ana Gómez',
      telefono: '3390 1122',
      tipo: TipoActividad.cita,
      programadaPara: el(1, 10, 0),
      descripcion: 'Cita en la tienda para ver modelos',
    ),
    ActividadAgenda(
      id: 'a6',
      cliente: 'María López',
      telefono: '5512 3456',
      tipo: TipoActividad.seguimiento,
      programadaPara: el(1, 14, 0),
      descripcion: 'Confirmar que recibió la cotización',
    ),
  ];
}
