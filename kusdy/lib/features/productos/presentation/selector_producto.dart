import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import 'productos_interes_providers.dart';

// Lista desplegable de productos, opcional. null = ninguno.
class SelectorProducto extends ConsumerWidget {
  const SelectorProducto({
    super.key,
    required this.valor,
    required this.alCambiar,
    this.textoNinguno = 'Ninguno',
  });

  final String? valor;
  final ValueChanged<String?> alCambiar;
  final String textoNinguno;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosInteresProvider);

    return productos.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Row(
        children: [
          const Expanded(
            child: Text(
              'No se pudieron cargar los productos.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(productosInteresProvider),
            child: const Text('Reintentar'),
          ),
        ],
      ),
      data: (lista) => DropdownButtonFormField<String?>(
        key: const Key('producto-interes'),
        // Si el producto ya no está activo, no rompe la lista.
        initialValue: lista.any((p) => p.id == valor) ? valor : null,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Producto de interés (opcional)',
        ),
        style: const TextStyle(
          fontFamily: fuenteKusdy,
          fontSize: 17,
          color: KusdyColors.texto,
        ),
        items: [
          DropdownMenuItem(value: null, child: Text(textoNinguno)),
          for (final p in lista)
            DropdownMenuItem(value: p.id, child: Text(p.nombre)),
        ],
        onChanged: alCambiar,
      ),
    );
  }
}
