import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../agenda/domain/actividad_agenda.dart';
import '../../agenda/domain/actividades_repository.dart';
import '../../agenda/domain/resultado_llamada.dart';
import '../../productos/presentation/selector_producto.dart';
import '../domain/opciones_resultado.dart';
import 'llamadas_providers.dart';
import 'reagendar_sheet.dart';

// Boceto 3 · "¿Qué pasó?" después de Hecho. Paso 1: el resultado. Paso 2:
// lo siguiente, según el resultado. Devuelve true si se guardó.
class QuePasoScreen extends ConsumerStatefulWidget {
  const QuePasoScreen({super.key, required this.actividad});

  final ActividadAgenda actividad;

  @override
  ConsumerState<QuePasoScreen> createState() => _QuePasoScreenState();
}

class _QuePasoScreenState extends ConsumerState<QuePasoScreen> {
  final _comentario = TextEditingController();
  ResultadoLlamada? _resultado;
  TipoActividad? _tipo;
  DateTime? _fecha;
  String? _productoId;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _elegir(ResultadoLlamada r) {
    final o = opcionesPara(r);
    final dias = o.dias;
    setState(() {
      _resultado = r;
      _productoId = null;
      _tipo = o.tipo;
      _fecha = (o.pideFecha && dias != null)
          ? fechaConAtajo(dias, DateTime.now())
          : null;
      _error = null;
    });
  }

  Future<void> _guardar() async {
    final resultado = _resultado!;
    final fecha = _fecha;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(seguimientoProvider)
          .registrar(
            RegistroLlamada(
              actividadId: widget.actividad.id,
              resultado: resultado,
              comentario: _comentario.text,
              siguienteTipo: fecha == null ? null : _tipo,
              siguienteFecha: fecha,
              productoInteresId: opcionesPara(resultado).pideProducto
                  ? _productoId
                  : null,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _guardando = false;
        _error = e is ActividadException
            ? e.mensaje
            : 'No se pudo guardar. Revisa tu conexión.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.actividad;
    final resultado = _resultado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué pasó?'),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${a.tipo.texto} con ${a.cliente}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (a.intentosSinRespuesta >= 3)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KusdyColors.vencidoSuave,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Van ${a.intentosSinRespuesta} llamadas sin respuesta.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 16),
          if (resultado == null) ..._resultados() else ..._siguiente(resultado),
        ],
      ),
    );
  }

  List<Widget> _resultados() => [
    for (final r in ResultadoLlamada.values)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () => _elegir(r),
          child: Text(r.texto),
        ),
      ),
  ];

  List<Widget> _siguiente(ResultadoLlamada resultado) {
    final o = opcionesPara(resultado);
    final fecha = _fecha;
    final tipo = _tipo;

    return [
      Row(
        children: [
          Expanded(
            child: Text(
              resultado.texto,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KusdyColors.primario,
              ),
            ),
          ),
          TextButton(
            onPressed: _guardando
                ? null
                : () => setState(() => _resultado = null),
            child: const Text('Cambiar'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(o.pregunta, style: const TextStyle(fontSize: 18)),
      if (o.pideFecha && tipo != null) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (dias, texto) in atajosDeFecha)
              ChoiceChip(
                label: Text(texto, style: const TextStyle(fontSize: 16)),
                selected:
                    fecha != null &&
                    mismoDia(fecha, fechaConAtajo(dias, DateTime.now())),
                onSelected: (_) => setState(
                  () => _fecha = fechaConAtajo(dias, DateTime.now()),
                ),
              ),
            ActionChip(
              avatar: const Icon(Icons.calendar_month, size: 18),
              label: const Text('Otra fecha', style: TextStyle(fontSize: 16)),
              onPressed: () async {
                final elegida = await elegirFechaYHora(
                  context,
                  fecha ?? fechaConAtajo(1, DateTime.now()),
                );
                if (elegida != null) setState(() => _fecha = elegida);
              },
            ),
            ChoiceChip(
              label: const Text('Sin agendar', style: TextStyle(fontSize: 16)),
              selected: fecha == null,
              onSelected: (_) => setState(() => _fecha = null),
            ),
          ],
        ),
        if (fecha != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<TipoActividad>(
            key: const Key('siguiente-tipo'),
            initialValue: tipo,
            decoration: const InputDecoration(
              labelText: 'Qué sigue',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in TipoActividad.values)
                DropdownMenuItem(value: t, child: Text(t.texto)),
            ],
            onChanged: (t) => setState(() => _tipo = t),
          ),
          const SizedBox(height: 8),
          Text(
            '${tipo.texto} el ${diaLargo(fecha)}, ${hora(fecha)}',
            style: const TextStyle(
              fontSize: 16,
              color: KusdyColors.textoSecundario,
            ),
          ),
        ],
      ],
      if (o.pideProducto) ...[
        const SizedBox(height: 16),
        SelectorProducto(
          valor: _productoId,
          textoNinguno: 'Sin cambiar',
          alCambiar: (id) => setState(() => _productoId = id),
        ),
      ],
      const SizedBox(height: 16),
      TextField(
        key: const Key('comentario-llamada'),
        controller: _comentario,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Comentario (opcional)',
          border: OutlineInputBorder(),
        ),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _error!,
            style: const TextStyle(color: KusdyColors.vencido, fontSize: 16),
          ),
        ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _guardando ? null : _guardar,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: _guardando
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : Text(_error == null ? 'Guardar' : 'Reintentar'),
      ),
    ];
  }
}
