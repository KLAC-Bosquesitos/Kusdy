import 'package:flutter/material.dart';

import '../../../core/utils/fechas.dart';
import '../domain/opciones_resultado.dart';

// Boceto 4 · Mover: atajos de fecha y, si hace falta, el calendario.
// Devuelve la fecha nueva o null si se cerró sin elegir.
Future<DateTime?> elegirNuevaFecha(BuildContext context, DateTime actual) {
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final (dias, texto) in atajosDeFecha)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 17),
                  ),
                  onPressed: () => Navigator.of(
                    contexto,
                  ).pop(fechaConAtajo(dias, DateTime.now(), horaDe: actual)),
                  child: Text(texto),
                ),
              ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                textStyle: const TextStyle(fontSize: 17),
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
