import '../../../core/utils/fechas.dart';
import '../domain/actividad_agenda.dart';
import '../domain/actividades_repository.dart';
import '../domain/filtro_agenda.dart';
import '../domain/resultado_llamada.dart';

// Se elige al correr la app: flutter run --dart-define=AGENDA_MODO=lento
enum ModoAgenda {
  normal,
  lento,
  // Falla la primera lectura: para probar Reintentar.
  error,
  vacio,
  // Lee bien, pero escribir falla.
  fallaBorrar;

  static ModoAgenda desdeEntorno() {
    const valor = String.fromEnvironment('AGENDA_MODO', defaultValue: 'normal');
    return ModoAgenda.values.firstWhere(
      (modo) => modo.name == valor,
      orElse: () => ModoAgenda.normal,
    );
  }
}

// Actividades en memoria para pruebas y para trabajar sin red. Una sola
// lista para Hoy y Agenda: lo que cambia en una se ve en la otra.
class ActividadesRepositoryFalso implements ActividadesRepository {
  ActividadesRepositoryFalso({
    this.modo = ModoAgenda.normal,
    List<ActividadAgenda>? actividades,
    this.demora = const Duration(milliseconds: 1200),
  }) : _actividades = [...(actividades ?? actividadesDeEjemplo())];

  final ModoAgenda modo;
  final Duration demora;
  final List<ActividadAgenda> _actividades;
  var _lecturas = 0;

  Future<void> _leer() async {
    _lecturas++;
    await Future.delayed(
      modo == ModoAgenda.lento ? const Duration(seconds: 6) : demora,
    );
    if (modo == ModoAgenda.error && _lecturas == 1) {
      throw Exception('Sin conexión (simulada)');
    }
  }

  Future<void> _escribir() async {
    await Future.delayed(demora ~/ 3);
    if (modo == ModoAgenda.fallaBorrar) {
      throw Exception('Sin conexión (simulada)');
    }
  }

  @override
  Future<List<ActividadAgenda>> pendientesDeHoy() async {
    await _leer();
    if (modo == ModoAgenda.vacio) return [];
    final manana = soloDia(DateTime.now()).add(const Duration(days: 1));
    return _actividades
        .where(
          (a) =>
              a.estado == EstadoActividad.pendiente &&
              a.programadaPara.isBefore(manana),
        )
        .toList()
      ..sort((a, b) => a.programadaPara.compareTo(b.programadaPara));
  }

  @override
  Future<List<ActividadAgenda>> obtenerActividades(FiltroAgenda filtro) async {
    await _leer();
    if (modo == ModoAgenda.vacio) return [];
    return _actividades
        .where(
          (a) =>
              a.estado != EstadoActividad.cancelada &&
              mismoDia(a.programadaPara, filtro.dia) &&
              (filtro.tipo == null || a.tipo == filtro.tipo),
        )
        .toList()
      ..sort((a, b) => a.programadaPara.compareTo(b.programadaPara));
  }

  @override
  Future<void> cancelarActividad(String id) async {
    await _escribir();
    _cambiar(id, (a) => a.copiar(estado: EstadoActividad.cancelada));
  }

  @override
  Future<void> reactivarActividad(String id) async {
    await _escribir();
    _cambiar(id, (a) => a.copiar(estado: EstadoActividad.pendiente));
  }

  @override
  Future<void> registrarResultado(RegistroLlamada registro) async {
    await _escribir();
    final actual = _cambiar(
      registro.actividadId,
      (a) => a.copiar(estado: EstadoActividad.completada),
    );
    final fecha = registro.siguienteFecha;
    if (actual == null || fecha == null) return;
    _actividades.add(
      ActividadAgenda(
        id: '${actual.id}-sig',
        clienteId: actual.clienteId,
        cliente: actual.cliente,
        telefono: actual.telefono,
        tipo: registro.siguienteTipo ?? TipoActividad.llamada,
        programadaPara: fecha,
        descripcion: registro.comentario ?? '',
      ),
    );
  }

  @override
  Future<void> reagendar(String id, DateTime nuevaFecha) async {
    await _escribir();
    _cambiar(id, (a) => a.copiar(programadaPara: nuevaFecha));
  }

  // Mismo id y mismos datos, como un UPDATE en la base.
  ActividadAgenda? _cambiar(
    String id,
    ActividadAgenda Function(ActividadAgenda) cambio,
  ) {
    final i = _actividades.indexWhere((a) => a.id == id);
    if (i == -1) return null;
    return _actividades[i] = cambio(_actividades[i]);
  }
}

// Fechas relativas a hoy, para que siempre haya datos.
List<ActividadAgenda> actividadesDeEjemplo([DateTime? hoy]) {
  final h = soloDia(hoy ?? DateTime.now());
  DateTime el(int dias, int hora, int minuto) =>
      DateTime(h.year, h.month, h.day + dias, hora, minuto);

  return [
    ActividadAgenda(
      id: 'a0',
      clienteId: '4',
      cliente: 'Ana Gómez',
      telefono: '3390 1122',
      tipo: TipoActividad.llamada,
      programadaPara: el(-1, 16, 0),
      descripcion: 'Preguntar si ya vio el catálogo',
    ),
    ActividadAgenda(
      id: 'a1',
      clienteId: '1',
      cliente: 'María López',
      telefono: '5512 3456',
      tipo: TipoActividad.llamada,
      programadaPara: el(0, 9, 0),
      descripcion: 'Enviar cotización del calentador 200 L',
    ),
    ActividadAgenda(
      id: 'a2',
      clienteId: '3',
      cliente: 'Hotel Los Altos',
      telefono: '7761 2030',
      tipo: TipoActividad.visita,
      programadaPara: el(0, 11, 30),
      descripcion: 'Visita técnica para medir el techo',
      intentosSinRespuesta: 3,
    ),
    ActividadAgenda(
      id: 'a3',
      clienteId: '5',
      cliente: 'Carlos Méndez',
      telefono: '5874 6655',
      tipo: TipoActividad.llamada,
      programadaPara: el(0, 15, 0),
      descripcion: '¿Ya decidió el calentador?',
    ),
    ActividadAgenda(
      id: 'a4',
      clienteId: '2',
      cliente: 'José Pérez',
      telefono: '4021 7788',
      tipo: TipoActividad.instalacion,
      programadaPara: el(0, 16, 30),
      descripcion: 'Instalación de paneles solares',
    ),
    ActividadAgenda(
      id: 'a5',
      clienteId: '4',
      cliente: 'Ana Gómez',
      telefono: '3390 1122',
      tipo: TipoActividad.cita,
      programadaPara: el(1, 10, 0),
      descripcion: 'Cita en la tienda para ver modelos',
    ),
    ActividadAgenda(
      id: 'a6',
      clienteId: '1',
      cliente: 'María López',
      telefono: '5512 3456',
      tipo: TipoActividad.seguimiento,
      programadaPara: el(1, 14, 0),
      descripcion: 'Confirmar que recibió la cotización',
    ),
  ];
}
