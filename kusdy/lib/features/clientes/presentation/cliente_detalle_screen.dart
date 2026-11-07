import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/utils/telefono.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../agenda/presentation/agenda_providers.dart';
import '../../hoy/presentation/hoy_providers.dart';
import '../domain/cliente.dart';
import '../domain/comentario.dart';
import '../domain/datos_cliente.dart';
import 'cliente_detalle_providers.dart';
import 'cliente_form_screen.dart';
import 'clientes_providers.dart';
import 'etiqueta_seguimiento.dart';

// HU-05 · Detalle del cliente con la tarjeta de Comentarios (pedido de Fredy:
// el último comentario siempre a la vista).
class ClienteDetalleScreen extends ConsumerWidget {
  const ClienteDetalleScreen({super.key, required this.clienteId});

  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteProvider(clienteId));

    return Scaffold(
      appBar: AppBar(
        title: Text(cliente.value?.nombre ?? 'Cliente'),
        actions: [
          if (cliente.value case final c?)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () => _editar(context, ref, c),
                child: const Text('Editar datos'),
              ),
            ),
        ],
      ),
      body: cliente.when(
        loading: () => const EstadoCargando(mensaje: 'Cargando cliente…'),
        error: (e, _) => EstadoError(
          mensaje: e is ClienteException
              ? e.mensaje
              : 'No pudimos cargar al cliente.\nRevisa tu conexión a internet.',
          onReintentar: () => ref.invalidate(clienteProvider(clienteId)),
        ),
        data: (c) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Datos(cliente: c),
              const SizedBox(height: 20),
              const Text(
                'Comentarios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _Comentarios(clienteId: c.id),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref, Cliente c) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClienteFormScreen(
          cliente: c,
          alGuardar: (datos) async {
            await ref
                .read(clientesRepositoryProvider)
                .actualizarCliente(c.id, datos);
            ref
              ..invalidate(clienteProvider(c.id))
              ..invalidate(clientesProvider)
              // Las tarjetas muestran la nota fija y el nombre del cliente.
              ..invalidate(pendientesHoyProvider)
              ..invalidate(agendaProvider);
          },
        ),
      ),
    );
  }
}

class _Datos extends StatelessWidget {
  const _Datos({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final c = cliente;
    final lugar = [c.direccion, c.ciudad].whereType<String>().join(', ');
    final proxima = c.proximaLlamada;
    final ultimo = c.ultimoContacto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ([lugar, ?c.producto].where((t) => t.isNotEmpty).toList()
            case final partes when partes.isNotEmpty)
          Text(
            partes.join(' · '),
            style: const TextStyle(
              fontSize: 17,
              color: KusdyColors.textoSecundario,
            ),
          ),
        const SizedBox(height: 8),
        EtiquetaSeguimiento(estado: EstadoSeguimiento.de(c, DateTime.now())),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => llamar(c.telefono),
                icon: const Icon(Icons.call),
                label: const Text('Llamar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => abrirWhatsApp(c.telefono),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp'),
              ),
            ),
          ],
        ),
        if (c.intentosSinRespuesta >= 3) ...[
          const SizedBox(height: 12),
          _Aviso(
            texto: 'Van ${c.intentosSinRespuesta} llamadas sin respuesta.',
            color: KusdyColors.vencidoSuave,
          ),
        ],
        if (c.notaFija case final nota?) ...[
          const SizedBox(height: 12),
          _Aviso(texto: nota, color: KusdyColors.avisoSuave),
        ],
        const SizedBox(height: 16),
        _Tarjeta(
          children: [
            _Dato(etiqueta: 'Teléfono', valor: c.telefono),
            if (lugar.isNotEmpty) _Dato(etiqueta: 'Dirección', valor: lugar),
            if (c.producto case final p?) _Dato(etiqueta: 'Producto', valor: p),
            _Dato(
              etiqueta: 'Próxima llamada',
              valor: proxima == null
                  ? 'Sin agendar'
                  : '${diaCercano(proxima, DateTime.now())}, ${hora(proxima)}',
            ),
            if (ultimo != null)
              _Dato(
                etiqueta: 'Último contacto',
                valor: diaCercano(ultimo, DateTime.now()),
              ),
            _Dato(etiqueta: 'Registrado', valor: diaLargo(c.registradoEl)),
          ],
        ),
      ],
    );
  }
}

class _Comentarios extends ConsumerStatefulWidget {
  const _Comentarios({required this.clienteId});

  final String clienteId;

  @override
  ConsumerState<_Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends ConsumerState<_Comentarios> {
  final _texto = TextEditingController();
  var _verTodos = false;
  var _enviando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final texto = _texto.text.trim();
    if (texto.isEmpty) return;
    setState(() => _enviando = true);
    final aviso = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(comentariosRepositoryProvider)
          .agregarComentario(widget.clienteId, texto);
      _texto.clear();
      ref
        ..invalidate(comentariosProvider(widget.clienteId))
        // Las tarjetas muestran el último comentario.
        ..invalidate(pendientesHoyProvider)
        ..invalidate(agendaProvider);
    } catch (_) {
      aviso.showSnackBar(
        const SnackBar(
          content: Text('No se guardó el comentario. Intenta de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comentarios = ref.watch(comentariosProvider(widget.clienteId));

    return _Tarjeta(
      children: [
        comentarios.when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Row(
            children: [
              const Expanded(
                child: Text(
                  'No pudimos cargar los comentarios.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(comentariosProvider(widget.clienteId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
          data: (lista) {
            if (lista.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin comentarios todavía.',
                  style: TextStyle(
                    fontSize: 16,
                    color: KusdyColors.textoSecundario,
                  ),
                ),
              );
            }
            final visibles = _verTodos ? lista : lista.take(1);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in visibles) _FilaComentario(comentario: c),
                if (lista.length > 1)
                  TextButton(
                    onPressed: () => setState(() => _verTodos = !_verTodos),
                    child: Text(
                      _verTodos ? 'Ver menos' : 'Ver todos (${lista.length})',
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('nuevo-comentario'),
          controller: _texto,
          minLines: 1,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 17),
          decoration: InputDecoration(
            hintText: 'Escribe un comentario',
            suffixIcon: _enviando
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Guardar comentario',
                    icon: const Icon(Icons.send),
                    onPressed: _agregar,
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilaComentario extends StatelessWidget {
  const _FilaComentario({required this.comentario});

  final Comentario comentario;

  @override
  Widget build(BuildContext context) {
    final c = comentario;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.texto, style: const TextStyle(fontSize: 17)),
          Text(
            '${c.autor} · ${diaLargo(c.creadoEn)}${c.editado ? ' (editado)' : ''}',
            style: const TextStyle(
              fontSize: 14,
              color: KusdyColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 16,
              color: KusdyColors.textoSecundario,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              capitalizar(valor),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 16)),
    );
  }
}
