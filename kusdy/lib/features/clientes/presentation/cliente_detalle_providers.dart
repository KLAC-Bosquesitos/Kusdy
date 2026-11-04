import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cliente.dart';
import '../domain/comentario.dart';
import 'clientes_providers.dart';

// Un provider por cliente (family): cada detalle tiene su propio estado.
final clienteProvider = FutureProvider.family<Cliente, String>(
  (ref, id) => ref.watch(clientesRepositoryProvider).obtenerCliente(id),
  retry: (_, _) => null,
);

final comentariosProvider = FutureProvider.family<List<Comentario>, String>(
  (ref, clienteId) =>
      ref.watch(comentariosRepositoryProvider).obtenerComentarios(clienteId),
  retry: (_, _) => null,
);
