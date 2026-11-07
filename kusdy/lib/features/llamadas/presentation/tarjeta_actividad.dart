import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/utils/telefono.dart';
import '../../agenda/domain/actividad_agenda.dart';
import '../../clientes/presentation/cliente_detalle_screen.dart';
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
        ? '${diaCercano(a.programadaPara, DateTime.now())}, ${hora(a.programadaPara)}'
        : hora(a.programadaPara);
    // La nota fija manda; sin ella, el último comentario.
    final nota = _conTexto(a.notaFija);
    final comentario = nota == null ? _conTexto(a.ultimoComentario) : null;
    // El comentario de una llamada también queda como nota de la siguiente
    // actividad: no se repite el mismo texto dos veces.
    final descripcion = _conTexto(a.descripcion);
    final conDescripcion = descripcion != null && descripcion != comentario;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: vencida
            ? const BorderSide(color: KusdyColors.vencidoBorde, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${vencida ? 'Vencía ' : ''}$cuando · ${a.tipo.texto}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: vencida ? KusdyColors.vencido : KusdyColors.primario,
              ),
            ),
            // Tocar el nombre abre el detalle: qué se habló la última vez.
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ClienteDetalleScreen(clienteId: a.clienteId),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        a.cliente,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: KusdyColors.texto,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: KusdyColors.textoSecundario,
                    ),
                  ],
                ),
              ),
            ),
            if (conDescripcion)
              Text(
                descripcion,
                style: const TextStyle(
                  fontSize: 16,
                  color: KusdyColors.textoSecundario,
                ),
              ),
            if (nota != null)
              _NotaDelCliente(icono: Icons.push_pin_outlined, texto: nota)
            else if (comentario != null)
              _NotaDelCliente(
                icono: Icons.chat_bubble_outline,
                texto: comentario,
              ),
            const SizedBox(height: 12),
            if (a.estado == EstadoActividad.pendiente)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: _compacto,
                      onPressed: () => llamar(a.telefono),
                      icon: const Icon(Icons.call),
                      label: const Text('Llamar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: _compacto,
                      onPressed: () => _hecho(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Hecho'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: _compacto,
                      onPressed: () => _mover(context, ref),
                      icon: const Icon(Icons.event_outlined),
                      label: const Text('Mover'),
                    ),
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: KusdyColors.exito),
                  SizedBox(width: 6),
                  Text(
                    'Hecha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: KusdyColors.exito,
                    ),
                  ),
                ],
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

String? _conTexto(String? texto) {
  final limpio = texto?.trim() ?? '';
  return limpio.isEmpty ? null : limpio;
}

// Nota fija (chincheta) o último comentario (globo). Va recortada a dos líneas
// para que la tarjeta no crezca; el texto completo está en el detalle.
class _NotaDelCliente extends StatelessWidget {
  const _NotaDelCliente({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: KusdyColors.textoSecundario),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, color: KusdyColors.texto),
            ),
          ),
        ],
      ),
    );
  }
}

// Tres botones en una fila: menos relleno para que quepan en pantallas chicas.
const _compacto = ButtonStyle(
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
  iconSize: WidgetStatePropertyAll(20),
);
