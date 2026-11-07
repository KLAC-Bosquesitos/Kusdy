import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../data/categorias_repository_provider.dart';
import '../domain/categoria_producto.dart';
import 'categoria_form_screen.dart';
import 'categorias_providers.dart';

// Lab S16 · CRUD de categorías de producto (Más → Categorías de productos).
// Lista con los 4 estados; tocar una categoría abre el formulario lleno;
// "+ Nueva" lo abre vacío. Después de cada cambio se invalida el provider.
class CategoriasScreen extends ConsumerWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías de productos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: categorias.when(
        skipLoadingOnReload: true,
        loading: () => const EstadoCargando(mensaje: 'Cargando categorías…'),
        error: (_, _) => EstadoError(
          mensaje:
              'No pudimos cargar las categorías.\n'
              'Revisa tu conexión a internet.',
          onReintentar: () => ref.invalidate(categoriasProvider),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return EstadoVacio(
              icono: Icons.category_outlined,
              mensaje: 'Aún no hay categorías.',
              textoAccion: 'Nueva categoría',
              onAccion: () => abrirFormulario(context, ref),
            );
          }
          return _ListaCategorias(categorias: lista);
        },
      ),
    );
  }
}

// Abre el formulario (vacío para crear, lleno para editar) y, si se guardó
// algo, refresca la lista invalidando el provider y avisa con un SnackBar.
Future<void> abrirFormulario(
  BuildContext context,
  WidgetRef ref, [
  CategoriaProducto? categoria,
]) async {
  final repo = ref.read(categoriasRepositoryProvider);
  final mensaje = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => CategoriaFormScreen(
        inicial: categoria,
        onGuardar: (nombre) => repo.guardar(id: categoria?.id, nombre: nombre),
        onArchivar: categoria == null
            ? null
            : () =>
                  repo.archivar(categoria.id, archivada: !categoria.archivada),
        onEliminar: categoria == null
            ? null
            : () => repo.eliminar(categoria.id),
      ),
    ),
  );
  if (mensaje == null) return; // Volvió sin guardar.
  ref.invalidate(categoriasProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

class _ListaCategorias extends ConsumerWidget {
  const _ListaCategorias({required this.categorias});

  final List<CategoriaProducto> categorias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activas = categorias.where((c) => !c.archivada).toList();
    final archivadas = categorias.where((c) => c.archivada).toList();

    return ListView(
      // Espacio abajo para que el botón "Nueva" no tape la última fila.
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final c in activas) _FilaCategoria(categoria: c),
        if (archivadas.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Archivadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: KusdyColors.textoSecundario,
              ),
            ),
          ),
          for (final c in archivadas) _FilaCategoria(categoria: c),
        ],
      ],
    );
  }
}

class _FilaCategoria extends ConsumerWidget {
  const _FilaCategoria({required this.categoria});

  final CategoriaProducto categoria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = switch (categoria.productos) {
      0 => 'Sin productos',
      1 => '1 producto',
      final n => '$n productos',
    };
    return ListTile(
      key: ValueKey(categoria.id),
      minTileHeight: 64,
      tileColor: KusdyColors.superficie,
      leading: Icon(
        categoria.archivada ? Icons.archive_outlined : Icons.category_outlined,
        color: categoria.archivada
            ? KusdyColors.bordeFuerte
            : KusdyColors.primario,
      ),
      title: Text(
        categoria.nombre,
        style: TextStyle(
          fontSize: 18,
          color: categoria.archivada
              ? KusdyColors.textoSecundario
              : KusdyColors.texto,
        ),
      ),
      subtitle: Text(
        categoria.archivada ? '$productos · archivada' : productos,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => abrirFormulario(context, ref, categoria),
    );
  }
}
