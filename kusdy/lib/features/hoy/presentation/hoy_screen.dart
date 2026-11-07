import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/pestana.dart';
import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../../agenda/domain/actividad_agenda.dart';
import '../../clientes/presentation/clientes_screen.dart';
import '../../llamadas/presentation/tarjeta_actividad.dart';
import 'hoy_providers.dart';

// HU-10 · Inicio "Clientes para hoy" (boceto 1). Los 4 estados de una lectura:
// cargando, error con Reintentar, vacío con acción y datos.
class HoyScreen extends ConsumerWidget {
  const HoyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(pendientesHoyProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizar(diaLargo(DateTime.now())),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: KusdyColors.textoSecundario,
              ),
            ),
            const Text('Clientes para hoy'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ver todos los clientes',
            icon: const Icon(Icons.people_outline),
            onPressed: () => _verClientes(ref),
          ),
        ],
      ),
      // Flotante: siempre a la mano, aunque la lista sea larga.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirNuevoCliente(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ingresar cliente'),
      ),
      body: pendientes.when(
        loading: () => const EstadoCargando(mensaje: 'Revisando tu día…'),
        error: (_, _) => EstadoError(
          mensaje:
              'No pudimos cargar tus pendientes de hoy.\n'
              'Revisa tu conexión a internet.',
          onReintentar: () => ref.invalidate(pendientesHoyProvider),
        ),
        data: (lista) => lista.isEmpty
            ? EstadoVacio(
                icono: Icons.event_available_outlined,
                mensaje: 'No tienes clientes para hoy.',
                textoAccion: 'Ver todos los clientes',
                iconoAccion: Icons.people_outline,
                onAccion: () => _verClientes(ref),
              )
            : _ListaPendientes(pendientes: lista),
      ),
    );
  }

  // No se abre una pantalla nueva encima: se cambia la pestaña activa y la
  // barra inferior sigue visible.
  void _verClientes(WidgetRef ref) {
    ref.read(pestanaProvider.notifier).ir(Pestana.clientes);
  }
}

// Arriba "Se te pasaron" (lo vencido, en rojo): es lo que más le preocupa
// a Fredy. Después, lo de hoy.
class _ListaPendientes extends StatelessWidget {
  const _ListaPendientes({required this.pendientes});

  final List<ActividadAgenda> pendientes;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final vencidas = pendientes.where((a) => a.vencida(ahora)).toList();
    final deHoy = pendientes.where((a) => !a.vencida(ahora)).toList();

    return ListView(
      // Abajo deja espacio para que el botón flotante no tape la última tarjeta.
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        if (vencidas.isNotEmpty) ...[
          _Titulo(
            'Se te pasaron (${vencidas.length})',
            color: KusdyColors.vencido,
            icono: Icons.error_outline,
          ),
          for (final a in vencidas)
            _conEspacio(TarjetaActividad(actividad: a, conFecha: true)),
          const SizedBox(height: 8),
        ],
        _Titulo('Hoy (${deHoy.length})', color: KusdyColors.texto),
        if (deHoy.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Nada más para hoy.',
              style: TextStyle(
                fontSize: 16,
                color: KusdyColors.textoSecundario,
              ),
            ),
          ),
        for (final a in deHoy) _conEspacio(TarjetaActividad(actividad: a)),
      ],
    );
  }

  Widget _conEspacio(Widget hijo) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: hijo);
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {required this.color, this.icono});

  final String texto;
  final Color color;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icono != null) ...[
            Icon(icono, color: color, size: 22),
            const SizedBox(width: 8),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
