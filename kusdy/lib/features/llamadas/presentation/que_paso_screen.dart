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

// Boceto 3 · "¿Qué pasó?" después de Hecho. Paso 1: el resultado, con botones
// grandes. Al elegir, se colapsan y sale el paso 2: lo siguiente, según el
// resultado. "Cambiar" los vuelve a abrir. Devuelve true si se guardó.
class QuePasoScreen extends ConsumerStatefulWidget {
  const QuePasoScreen({super.key, required this.actividad});

  final ActividadAgenda actividad;

  @override
  ConsumerState<QuePasoScreen> createState() => _QuePasoScreenState();
}

class _QuePasoScreenState extends ConsumerState<QuePasoScreen> {
  final _comentario = TextEditingController();
  ResultadoLlamada? _resultado;
  var _cambiando = false;
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
    // Si vuelve a tocar el mismo, se conserva la fecha que ya había elegido.
    if (r == _resultado) {
      setState(() => _cambiando = false);
      return;
    }
    final o = opcionesPara(r);
    final dias = o.dias;
    setState(() {
      _resultado = r;
      _cambiando = false;
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
    // null mientras los botones están abiertos: aún no hay paso 2 ni Guardar.
    final elegido = _cambiando ? null : resultado;

    return Scaffold(
      appBar: AppBar(title: const Text('¿Qué pasó?')),
      // Columna y no ListView: el formulario es corto y todo queda armado.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${a.tipo.texto} con ${a.cliente}',
              style: const TextStyle(
                fontSize: 17,
                color: KusdyColors.textoSecundario,
              ),
            ),
            if (a.intentosSinRespuesta >= 3)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KusdyColors.vencidoSuave,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Van ${a.intentosSinRespuesta} llamadas sin respuesta.',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: elegido == null
                  ? _opciones(resultado)
                  : _ResultadoElegido(
                      resultado: elegido,
                      onCambiar: _guardando
                          ? null
                          : () => setState(() => _cambiando = true),
                    ),
            ),
            if (elegido != null) ..._siguiente(elegido),
          ],
        ),
      ),
      bottomNavigationBar: elegido == null ? null : _barraGuardar(),
    );
  }

  Widget _opciones(ResultadoLlamada? actual) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _Pregunta('¿Cómo te fue?'),
      for (final r in ResultadoLlamada.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _BotonResultado(
            resultado: r,
            elegido: r == actual,
            onPressed: () => _elegir(r),
          ),
        ),
    ],
  );

  Widget _barraGuardar() => Container(
    decoration: const BoxDecoration(
      color: KusdyColors.superficie,
      border: Border(top: BorderSide(color: KusdyColors.borde)),
    ),
    padding: EdgeInsets.fromLTRB(
      16,
      12,
      16,
      12 + MediaQuery.viewPaddingOf(context).bottom,
    ),
    child: FilledButton(
      onPressed: _guardando ? null : _guardar,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      child: _guardando
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : Text(_error == null ? 'Guardar' : 'Reintentar'),
    ),
  );

  List<Widget> _siguiente(ResultadoLlamada resultado) {
    final o = opcionesPara(resultado);
    final fecha = _fecha;
    final tipo = _tipo;

    return [
      const SizedBox(height: 20),
      _Pregunta(o.pregunta),
      if (o.pideFecha && tipo != null) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (dias, texto) in atajosDeFecha)
              ChoiceChip(
                label: Text(texto),
                selected:
                    fecha != null &&
                    mismoDia(fecha, fechaConAtajo(dias, DateTime.now())),
                onSelected: (_) => setState(
                  () => _fecha = fechaConAtajo(dias, DateTime.now()),
                ),
              ),
            ActionChip(
              avatar: const Icon(Icons.calendar_month, size: 18),
              label: const Text('Otra fecha'),
              onPressed: () async {
                final elegida = await elegirFechaYHora(
                  context,
                  fecha ?? fechaConAtajo(1, DateTime.now()),
                );
                if (elegida != null) setState(() => _fecha = elegida);
              },
            ),
            ChoiceChip(
              label: const Text('Sin agendar'),
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
            decoration: const InputDecoration(labelText: 'Qué sigue'),
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
        decoration: const InputDecoration(labelText: 'Comentario (opcional)'),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _error!,
            style: const TextStyle(color: KusdyColors.vencido, fontSize: 16),
          ),
        ),
    ];
  }
}

IconData _iconoDe(ResultadoLlamada r) {
  return switch (r) {
    ResultadoLlamada.noContesto => Icons.phone_missed_outlined,
    ResultadoLlamada.interesado => Icons.thumb_up_outlined,
    ResultadoLlamada.pidioCotizacion => Icons.request_quote_outlined,
    ResultadoLlamada.agendoVisita => Icons.event_available_outlined,
    ResultadoLlamada.compro => Icons.sell_outlined,
    ResultadoLlamada.noInteresado => Icons.thumb_down_outlined,
    ResultadoLlamada.numeroEquivocado => Icons.phone_disabled_outlined,
    ResultadoLlamada.noVolverALlamar => Icons.do_not_disturb_on_outlined,
  };
}

class _BotonResultado extends StatelessWidget {
  const _BotonResultado({
    required this.resultado,
    required this.elegido,
    required this.onPressed,
  });

  final ResultadoLlamada resultado;
  final bool elegido;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        foregroundColor: KusdyColors.texto,
        backgroundColor: elegido
            ? KusdyColors.primarioSuave
            : KusdyColors.superficie,
        side: BorderSide(
          color: elegido ? KusdyColors.primario : KusdyColors.bordeFuerte,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(_iconoDe(resultado), size: 26, color: KusdyColors.primario),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              resultado.texto,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ),
          if (elegido)
            const Icon(Icons.check, size: 26, color: KusdyColors.primario),
        ],
      ),
    );
  }
}

// Los botones ya colapsados: qué se eligió y cómo corregirlo.
class _ResultadoElegido extends StatelessWidget {
  const _ResultadoElegido({required this.resultado, required this.onCambiar});

  final ResultadoLlamada resultado;
  final VoidCallback? onCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: KusdyColors.primarioSuave,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_iconoDe(resultado), size: 26, color: KusdyColors.primario),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              resultado.texto,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: KusdyColors.texto,
              ),
            ),
          ),
          TextButton(onPressed: onCambiar, child: const Text('Cambiar')),
        ],
      ),
    );
  }
}

class _Pregunta extends StatelessWidget {
  const _Pregunta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}
