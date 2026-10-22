import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../../clientes/presentation/clientes_screen.dart';
import '../domain/pendiente_hoy.dart';
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
        title: const Text('Clientes para hoy'),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
        actions: [
          IconButton(
            tooltip: 'Ver todos los clientes',
            icon: const Icon(Icons.people_outline),
            onPressed: () => _verClientes(context),
          ),
        ],
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
                onAccion: () => _verClientes(context),
              )
            : _ListaPendientes(pendientes: lista),
      ),
    );
  }

  void _verClientes(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ClientesScreen()));
  }
}

class _ListaPendientes extends StatelessWidget {
  const _ListaPendientes({required this.pendientes});

  final List<PendienteHoy> pendientes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pendientes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TarjetaPendiente(pendiente: pendientes[i]),
    );
  }
}

class _TarjetaPendiente extends StatelessWidget {
  const _TarjetaPendiente({required this.pendiente});

  final PendienteHoy pendiente;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: KusdyColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: KusdyColors.borde),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(
          pendiente.hora,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: KusdyColors.primario,
          ),
        ),
        title: Text(
          pendiente.cliente,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${pendiente.motivo}\n${pendiente.telefono}',
          style: const TextStyle(
            fontSize: 15,
            color: KusdyColors.textoSecundario,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
