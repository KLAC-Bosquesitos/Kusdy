import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../domain/opciones_resultado.dart';

// Boceto 4 · Mover: atajos de fecha y, si hace falta, el calendario.
// Devuelve la fecha nueva o null si se cerró sin elegir.
Future<DateTime?> elegirNuevaFecha(BuildContext context, DateTime actual) {
  final ahora = DateTime.now();
  final vencida = soloDia(actual).isBefore(soloDia(ahora));
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mover para…',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: vencida
                    ? KusdyColors.vencidoSuave
                    : KusdyColors.primarioSuave,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Estaba para ${diaCercano(actual, ahora)} a las ${hora(actual)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: vencida
                      ? KusdyColors.vencido
                      : KusdyColors.primarioOscuro,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final (i, (dias, texto)) in atajosDeFecha.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      onPressed: () => Navigator.of(contexto).pop(
                        fechaConAtajo(dias, DateTime.now(), horaDe: actual),
                      ),
                      child: Text(texto, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Otra fecha'),
              onPressed: () async {
                final fecha = await elegirFechaYHora(contexto, actual);
                if (fecha != null && contexto.mounted) {
                  Navigator.of(contexto).pop(fecha);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// Calendario y reloj, solo cuando los atajos no sirven.
Future<DateTime?> elegirFechaYHora(
  BuildContext context,
  DateTime inicial,
) async {
  final hoy = soloDia(DateTime.now());
  final dia = await showDatePicker(
    context: context,
    initialDate: inicial.isBefore(hoy) ? hoy : inicial,
    firstDate: hoy,
    lastDate: hoy.add(const Duration(days: 365)),
  );
  if (dia == null || !context.mounted) return null;
  final hora = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(inicial),
  );
  if (hora == null) return null;
  return DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);
}
