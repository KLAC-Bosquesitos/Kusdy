import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/utils/telefono.dart';
import '../../agenda/domain/actividad_agenda.dart';
import 'llamadas_providers.dart';
import 'que_paso_screen.dart';
import 'reagendar_sheet.dart';

// Tarjeta de Hoy y Agenda con las acciones del boceto 1: Llamar, Hecho y Mover.
class TarjetaActividad extends ConsumerWidget {
  const TarjetaActividad({
    super.key,
    required this.actividad,
    this.conFecha = false,
  });

  final ActividadAgenda actividad;

  // En "Se te pasaron" importa el día, no solo la hora.
  final bool conFecha;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = actividad;
    final vencida = a.vencida(DateTime.now());
    final cuando = conFecha
        ? '${diaLargo(a.programadaPara)}, ${hora(a.programadaPara)}'
        : hora(a.programadaPara);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: KusdyColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: vencida ? KusdyColors.vencido : KusdyColors.borde,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$cuando · ${a.tipo.texto}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: vencida ? KusdyColors.vencido : KusdyColors.primario,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              a.cliente,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              [
                if (a.descripcion.isNotEmpty) a.descripcion,
                a.telefono,
              ].join('\n'),
              style: const TextStyle(
                fontSize: 15,
                color: KusdyColors.textoSecundario,
              ),
            ),
            if (a.estado == EstadoActividad.pendiente)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => llamar(a.telefono),
                    icon: const Icon(Icons.call),
                    label: const Text('Llamar'),
                  ),
                  TextButton.icon(
                    onPressed: () => _mover(context, ref),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Mover'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _hecho(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Hecho'),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Hecha',
                  style: TextStyle(fontSize: 15, color: KusdyColors.exito),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _hecho(BuildContext context) async {
    final aviso = ScaffoldMessenger.of(context);
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => QuePasoScreen(actividad: actividad)),
    );
    if (guardado == true) {
      aviso.showSnackBar(
        SnackBar(content: Text('Listo: ${actividad.cliente}.')),
      );
    }
  }

  Future<void> _mover(BuildContext context, WidgetRef ref) async {
    final aviso = ScaffoldMessenger.of(context);
    final fecha = await elegirNuevaFecha(context, actividad.programadaPara);
    if (fecha == null) return;
    try {
      await ref.read(seguimientoProvider).reagendar(actividad.id, fecha);
      aviso.showSnackBar(
        SnackBar(
          content: Text('Movida al ${diaLargo(fecha)}, ${hora(fecha)}.'),
        ),
      );
    } catch (_) {
      aviso.showSnackBar(
        const SnackBar(content: Text('No se pudo mover. Revisa tu conexión.')),
      );
    }
  }
}
