import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../../agenda/presentation/agenda_providers.dart';
import '../../hoy/presentation/hoy_providers.dart';
import '../domain/cliente.dart';
import 'cliente_detalle_screen.dart';
import 'cliente_form_screen.dart';
import 'etiqueta_seguimiento.dart';
import 'clientes_providers.dart';

// HU-03 · Consultar clientes y HU-13 · Filtrar clientes (por ahora búsqueda y
// mes de registro). Los 4 estados de una lectura, el vacío según el filtro y
// borrar deslizando con Deshacer.
class ClientesScreen extends ConsumerWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(clientesProvider);
    final filtro = ref.watch(filtroClientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => _agregarCliente(context, ref),
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _BarraFiltros(),
          // Al cambiar el filtro se queda la lista anterior y aparece esta
          // barrita, en vez de borrar la pantalla en cada letra.
          if (clientes.isLoading && clientes.hasValue)
            const LinearProgressIndicator(minHeight: 3)
          else
            const SizedBox(height: 3),
          Expanded(
            child: clientes.when(
              skipLoadingOnReload: true,
              loading: () =>
                  const EstadoCargando(mensaje: 'Cargando clientes…'),
              error: (_, _) => EstadoError(
                mensaje:
                    'No pudimos cargar tus clientes.\n'
                    'Revisa tu conexión a internet.',
                onReintentar: () => ref.invalidate(clientesProvider),
              ),
              data: (lista) {
                if (lista.isNotEmpty) return _ListaClientes(clientes: lista);
                // Vacío según el filtro: no es lo mismo "no tienes clientes"
                // que "ninguno coincide con lo que elegiste".
                if (filtro.activo) {
                  return EstadoVacio(
                    icono: Icons.search_off,
                    mensaje: 'No hay clientes con estos filtros.',
                    textoAccion: 'Quitar filtros',
                    iconoAccion: Icons.filter_alt_off_outlined,
                    onAccion: () => ref
                        .read(filtroClientesProvider.notifier)
                        .quitarFiltros(),
                  );
                }
                return EstadoVacio(
                  icono: Icons.people_outline,
                  mensaje: 'Aún no tienes clientes.',
                  textoAccion: 'Agregar cliente',
                  onAccion: () => _agregarCliente(context, ref),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarCliente(BuildContext context, WidgetRef ref) =>
      abrirNuevoCliente(context, ref);
}

// Formulario de cliente nuevo; también se abre desde Hoy.
Future<void> abrirNuevoCliente(BuildContext context, WidgetRef ref) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ClienteFormScreen(
        alGuardar: (datos) async {
          await ref.read(clientesRepositoryProvider).crearCliente(datos);
          // La primera llamada debe verse ya en Hoy y Agenda.
          ref
            ..invalidate(clientesProvider)
            ..invalidate(pendientesHoyProvider)
            ..invalidate(agendaProvider);
        },
      ),
    ),
  );
}

// Búsqueda y mes de registro. Solo cambia el filtro; la lista reacciona sola.
class _BarraFiltros extends ConsumerStatefulWidget {
  const _BarraFiltros();

  @override
  ConsumerState<_BarraFiltros> createState() => _BarraFiltrosState();
}

class _BarraFiltrosState extends ConsumerState<_BarraFiltros> {
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(filtroClientesProvider);
    final notifier = ref.read(filtroClientesProvider.notifier);

    // Si alguien quita los filtros desde otro lado, el texto también se borra.
    ref.listen(filtroClientesProvider, (_, nuevo) {
      if (_busqueda.text != nuevo.texto) _busqueda.text = nuevo.texto;
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _busqueda,
            onChanged: notifier.buscar,
            style: const TextStyle(fontSize: 17),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o teléfono',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filtro.texto.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _busqueda.clear();
                        notifier.buscar('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Mes de registro',
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DateTime?>(
                key: const Key('filtro-mes'),
                value: filtro.mes,
                isExpanded: true,
                style: const TextStyle(
                  fontFamily: fuenteKusdy,
                  fontSize: 17,
                  color: KusdyColors.texto,
                ),
                onChanged: notifier.elegirMes,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todos los meses'),
                  ),
                  for (final mes in ultimosMeses(DateTime.now()))
                    DropdownMenuItem(value: mes, child: Text(mesYAnio(mes))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Los últimos 6 meses, empezando por el actual (día 1 de cada mes).
List<DateTime> ultimosMeses(DateTime hoy, {int cuantos = 6}) {
  return [for (var i = 0; i < cuantos; i++) DateTime(hoy.year, hoy.month - i)];
}

class _ListaClientes extends ConsumerWidget {
  const _ListaClientes({required this.clientes});

  final List<Cliente> clientes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: clientes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final cliente = clientes[i];
        return Dismissible(
          // La key es el id del cliente, nunca la posición: al borrar uno,
          // los de abajo suben de lugar pero siguen siendo los mismos.
          key: ValueKey(cliente.id),
          direction: DismissDirection.endToStart,
          background: const _FondoEliminar(),
          confirmDismiss: (_) => _eliminarEnBase(context, ref, cliente),
          onDismissed: (_) => _avisarEliminado(context, ref, cliente),
          child: _TarjetaCliente(cliente: cliente),
        );
      },
    );
  }

  // Primero se borra en la base. Devolver false hace que la fila regrese.
  Future<bool> _eliminarEnBase(
    BuildContext context,
    WidgetRef ref,
    Cliente cliente,
  ) async {
    final aviso = ScaffoldMessenger.of(context);
    try {
      await ref.read(clientesProvider.notifier).eliminarEnBase(cliente.id);
      return true;
    } catch (_) {
      aviso
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo eliminar a ${cliente.nombre}. '
              'Revisa tu conexión.',
            ),
          ),
        );
      return false;
    }
  }

  // Ya se borró en la base: se quita de la pantalla y se ofrece Deshacer.
  void _avisarEliminado(BuildContext context, WidgetRef ref, Cliente cliente) {
    final aviso = ScaffoldMessenger.of(context);
    // Se guarda el contenedor y no el ref: si era el último cliente, esta
    // lista desaparece y su ref ya no se puede usar cuando tocan Deshacer.
    final contenedor = ProviderScope.containerOf(context);
    ref.read(clientesProvider.notifier).quitarDeLaLista(cliente.id);

    aviso
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Se eliminó a ${cliente.nombre}.'),
          duration: const Duration(seconds: 6),
          // Con una acción, Flutter deja el aviso fijo si no se indica esto.
          persist: false,
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              try {
                await contenedor
                    .read(clientesProvider.notifier)
                    .restaurar(cliente.id);
              } catch (_) {
                aviso.showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se pudo recuperar a ${cliente.nombre}. '
                      'Intenta de nuevo.',
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
  }
}

class _FondoEliminar extends StatelessWidget {
  const _FondoEliminar();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: KusdyColors.vencido,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Eliminar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCliente extends StatelessWidget {
  const _TarjetaCliente({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final producto = cliente.producto;
    final estado = EstadoSeguimiento.de(cliente, DateTime.now());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ClienteDetalleScreen(clienteId: cliente.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: KusdyColors.primarioSuave,
                foregroundColor: KusdyColors.primarioOscuro,
                child: Text(
                  iniciales(cliente.nombre),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      producto == null
                          ? cliente.telefono
                          : '${cliente.telefono} · $producto',
                      style: const TextStyle(
                        fontSize: 15,
                        color: KusdyColors.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 4),
                    EtiquetaSeguimiento(estado: estado),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// "María López" -> "ML"; "Hotel Los Altos" -> "HL".
String iniciales(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  return partes
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p.characters.first.toUpperCase())
      .join();
}
