import '../../agenda/domain/actividad_agenda.dart';
import '../../agenda/domain/resultado_llamada.dart';

// Qué ofrece "¿Qué pasó?" después de elegir un resultado (boceto 3, pedido
// de Fredy: la pantalla cambia según lo que pasó).
class OpcionesResultado {
  const OpcionesResultado({
    required this.pregunta,
    this.tipo,
    this.dias,
    this.pideFecha = true,
    this.pideProducto = false,
  });

  final String pregunta;
  final TipoActividad? tipo;

  // Atajo elegido al abrir; null = "Sin agendar".
  final int? dias;

  // false: el resultado cierra el seguimiento (no se ofrece fecha).
  final bool pideFecha;

  // Si el cliente mostró interés, se pregunta en qué producto.
  final bool pideProducto;
}

OpcionesResultado opcionesPara(ResultadoLlamada r) {
  return switch (r) {
    ResultadoLlamada.noContesto => const OpcionesResultado(
      pregunta: '¿Cuándo vuelves a llamar?',
      tipo: TipoActividad.llamada,
      dias: 1,
    ),
    ResultadoLlamada.interesado => const OpcionesResultado(
      pregunta: '¿Cuándo le das seguimiento?',
      tipo: TipoActividad.llamada,
      dias: 3,
      pideProducto: true,
    ),
    ResultadoLlamada.pidioCotizacion => const OpcionesResultado(
      pregunta: '¿Cuándo confirmas que recibió la cotización?',
      tipo: TipoActividad.seguimiento,
      dias: 1,
      pideProducto: true,
    ),
    ResultadoLlamada.agendoVisita => const OpcionesResultado(
      pregunta: '¿Cuándo es la visita?',
      tipo: TipoActividad.visita,
      dias: 1,
      pideProducto: true,
    ),
    ResultadoLlamada.compro => const OpcionesResultado(
      pregunta: '¿Cuándo es la instalación?',
      tipo: TipoActividad.instalacion,
      dias: 7,
      pideProducto: true,
    ),
    // "No le interesa" = perdido, pero se puede volver a intentar.
    ResultadoLlamada.noInteresado => const OpcionesResultado(
      pregunta: '¿Volver a intentar más adelante?',
      tipo: TipoActividad.llamada,
    ),
    ResultadoLlamada.numeroEquivocado ||
    ResultadoLlamada.noVolverALlamar => const OpcionesResultado(
      pregunta: 'Se cierra el seguimiento de este cliente.',
      pideFecha: false,
    ),
  };
}

// Atajos de fecha: (días, texto).
const atajosDeFecha = [(1, 'Mañana'), (3, 'En 3 días'), (7, 'En 1 semana')];

// El día del atajo, a la misma hora que tenía la actividad.
DateTime fechaConAtajo(int dias, DateTime ahora, {DateTime? horaDe}) {
  final h = horaDe ?? DateTime(ahora.year, ahora.month, ahora.day, 9);
  return DateTime(ahora.year, ahora.month, ahora.day + dias, h.hour, h.minute);
}
