import 'actividad_agenda.dart';

// Mismos valores que el enum resultado_llamada de Postgres.
enum ResultadoLlamada {
  noContesto('no_contesto', 'No contestó'),
  interesado('interesado', 'Le interesa'),
  pidioCotizacion('pidio_cotizacion', 'Pidió cotización'),
  agendoVisita('agendo_visita', 'Agendó visita'),
  compro('compro', 'Compró'),
  noInteresado('no_interesado', 'No le interesa'),
  numeroEquivocado('numero_equivocado', 'Número equivocado'),
  noVolverALlamar('no_volver_a_llamar', 'No volver a llamar');

  const ResultadoLlamada(this.valor, this.texto);

  // Como se guarda en la base.
  final String valor;
  final String texto;
}

// Lo que se guarda al tocar Hecho: el resultado y, si hay, lo siguiente.
class RegistroLlamada {
  const RegistroLlamada({
    required this.actividadId,
    required this.resultado,
    this.comentario,
    this.siguienteTipo,
    this.siguienteFecha,
  });

  final String actividadId;
  final ResultadoLlamada resultado;
  final String? comentario;
  final TipoActividad? siguienteTipo;
  final DateTime? siguienteFecha;
}
