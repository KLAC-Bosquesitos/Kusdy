import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../domain/cliente.dart';
import 'clientes_providers.dart';

// HU-03 · Consultar clientes. Muestra los 4 estados de una lectura:
// cargando, error con Reintentar, vacío con acción y datos.
class ClientesScreen extends ConsumerWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
      ),
      body: clientes.when(
        loading: () => const EstadoCargando(mensaje: 'Cargando clientes…'),
        error: (_, _) => EstadoError(
          mensaje:
              'No pudimos cargar tus clientes.\n'
              'Revisa tu conexión a internet.',
          onReintentar: () => ref.invalidate(clientesProvider),
        ),
        data: (lista) => lista.isEmpty
            ? EstadoVacio(
                icono: Icons.people_outline,
                mensaje: 'Aún no tienes clientes.',
                textoAccion: 'Agregar cliente',
                onAccion: () => _agregarCliente(context),
              )
            : _ListaClientes(clientes: lista),
      ),
    );
  }

  // El formulario de cliente (bocetos 5 y 6) es otra historia de usuario.
  void _agregarCliente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Muy pronto podrás agregar clientes.')),
    );
  }
}

class _ListaClientes extends StatelessWidget {
  const _ListaClientes({required this.clientes});

  final List<Cliente> clientes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: clientes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TarjetaCliente(cliente: clientes[i]),
    );
  }
}

class _TarjetaCliente extends StatelessWidget {
  const _TarjetaCliente({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final producto = cliente.producto;

    return Card(
      elevation: 0,
      color: KusdyColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: KusdyColors.borde),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: KusdyColors.primarioSuave,
          foregroundColor: KusdyColors.primarioOscuro,
          child: Text(cliente.nombre.characters.first),
        ),
        title: Text(
          cliente.nombre,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          producto == null
              ? cliente.telefono
              : '${cliente.telefono} · $producto',
          style: const TextStyle(
            fontSize: 15,
            color: KusdyColors.textoSecundario,
          ),
        ),
      ),
    );
  }
}
