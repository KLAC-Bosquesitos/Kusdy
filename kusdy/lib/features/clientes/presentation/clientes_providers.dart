import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/clientes_repository_falso.dart';
import '../domain/cliente.dart';
import '../domain/clientes_repository.dart';

// Qué repositorio usa la app. Las pruebas lo reemplazan con overrideWithValue.
final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  return ClientesRepositoryFalso(modo: ModoFalso.desdeEntorno());
});

// La lista de clientes. Para recargar: ref.invalidate(clientesProvider).
final clientesProvider = FutureProvider<List<Cliente>>(
  (ref) => ref.watch(clientesRepositoryProvider).obtenerClientes(),
  // Riverpod 3 reintenta solo cuando hay error, y eso escondería el estado
  // de error. Lo desactivamos: el usuario decide cuándo reintentar.
  retry: (_, _) => null,
);
