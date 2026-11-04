import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/utils/telefono.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../domain/cliente.dart';
import '../domain/comentario.dart';
import '../domain/datos_cliente.dart';
import 'cliente_detalle_providers.dart';
import 'cliente_form_screen.dart';
import 'clientes_providers.dart';

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
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
        actions: [
          if (cliente.value case final c?)
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editar(context, ref, c),
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
        data: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Datos(cliente: c),
            const SizedBox(height: 16),
            _Comentarios(clienteId: c.id),
          ],
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
              ..invalidate(clientesProvider);
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

    return _Tarjeta(
      children: [
        Text(
          c.telefono,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => llamar(c.telefono),
                icon: const Icon(Icons.call),
                label: const Text('Llamar'),
                style: _botonGrande,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => abrirWhatsApp(c.telefono),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp'),
                style: _botonGrande,
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
        const SizedBox(height: 8),
        if (lugar.isNotEmpty) _Dato(icono: Icons.place_outlined, texto: lugar),
        if (c.producto case final p?)
          _Dato(icono: Icons.solar_power_outlined, texto: p),
        _Dato(
          icono: Icons.event_outlined,
          texto: proxima == null
              ? 'Sin llamada agendada'
              : 'Próxima: ${diaLargo(proxima)}, ${hora(proxima)}',
        ),
        if (ultimo != null)
          _Dato(
            icono: Icons.history,
            texto: 'Último contacto: ${diaLargo(ultimo)}',
          ),
        _Dato(
          icono: Icons.person_add_alt,
          texto: 'Registrado: ${diaLargo(c.registradoEl)}',
        ),
      ],
    );
  }
}

final _botonGrande = ButtonStyle(
  minimumSize: WidgetStateProperty.all(const Size.fromHeight(52)),
  textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 17)),
);

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
      ref.invalidate(comentariosProvider(widget.clienteId));
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
        const Text(
          'Comentarios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
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
            border: const OutlineInputBorder(),
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
      elevation: 0,
      margin: EdgeInsets.zero,
      color: KusdyColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: KusdyColors.borde),
      ),
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
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, size: 20, color: KusdyColors.textoSecundario),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 16))),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 16)),
    );
  }
}
