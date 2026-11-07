import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../domain/cliente.dart';

// Cómo va el seguimiento del cliente, según su próxima llamada.
enum TipoSeguimiento { vencido, hoy, programado, sinFecha }

class EstadoSeguimiento {
  const EstadoSeguimiento(this.tipo, this.texto);

  factory EstadoSeguimiento.de(Cliente cliente, DateTime ahora) {
    final proxima = cliente.proximaLlamada;
    if (proxima == null) {
      return const EstadoSeguimiento(
        TipoSeguimiento.sinFecha,
        'Sin llamada agendada',
      );
    }
    final cuando = '${diaCercano(proxima, ahora)}, ${hora(proxima)}';
    if (soloDia(proxima).isBefore(soloDia(ahora))) {
      return EstadoSeguimiento(TipoSeguimiento.vencido, 'Vencida: $cuando');
    }
    if (mismoDia(proxima, ahora)) {
      return EstadoSeguimiento(
        TipoSeguimiento.hoy,
        'Llamar hoy, ${hora(proxima)}',
      );
    }
    return EstadoSeguimiento(TipoSeguimiento.programado, 'Próxima: $cuando');
  }

  final TipoSeguimiento tipo;
  final String texto;
}

// Etiqueta de color con ícono: el estado no depende solo del color.
class EtiquetaSeguimiento extends StatelessWidget {
  const EtiquetaSeguimiento({super.key, required this.estado});

  final EstadoSeguimiento estado;

  @override
  Widget build(BuildContext context) {
    final (fondo, color, icono) = switch (estado.tipo) {
      TipoSeguimiento.vencido => (
        KusdyColors.vencidoSuave,
        KusdyColors.vencido,
        Icons.error_outline,
      ),
      TipoSeguimiento.hoy => (
        KusdyColors.primarioSuave,
        KusdyColors.primarioOscuro,
        Icons.call,
      ),
      TipoSeguimiento.programado => (
        KusdyColors.exitoSuave,
        KusdyColors.exito,
        Icons.event_available,
      ),
      TipoSeguimiento.sinFecha => (
        KusdyColors.avisoSuave,
        KusdyColors.aviso,
        Icons.event_busy,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              estado.texto,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
