import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/clientes_repository_falso.dart';
import '../domain/cliente.dart';
import '../domain/clientes_repository.dart';
import '../domain/filtro_clientes.dart';

// Qué repositorio usa la app. Las pruebas lo reemplazan con overrideWithValue.
final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  return ClientesRepositoryFalso(modo: ModoFalso.desdeEntorno());
});

// El filtro activo. Cada método reemplaza el filtro por uno nuevo.
class FiltroClientesNotifier extends Notifier<FiltroClientes> {
  @override
  FiltroClientes build() => const FiltroClientes();

  void buscar(String texto) {
    state = FiltroClientes(texto: texto, mes: state.mes);
  }

  void elegirMes(DateTime? mes) {
    state = FiltroClientes(texto: state.texto, mes: mes);
  }

  void quitarFiltros() => state = const FiltroClientes();
}

final filtroClientesProvider =
    NotifierProvider<FiltroClientesNotifier, FiltroClientes>(
      FiltroClientesNotifier.new,
    );

// La lista de clientes. Hace watch del filtro: cuando el filtro cambia,
// build() se vuelve a ejecutar solo, sin botón de "recargar".
// Para recargar a mano: ref.invalidate(clientesProvider).
class ClientesNotifier extends AsyncNotifier<List<Cliente>> {
  @override
  Future<List<Cliente>> build() {
    final filtro = ref.watch(filtroClientesProvider);
    return ref.watch(clientesRepositoryProvider).obtenerClientes(filtro);
  }

  // Paso 1 de borrar: primero en la base. Si falla, lanza el error y la
  // pantalla deja la fila donde estaba.
  Future<void> eliminarEnBase(String id) {
    return ref.read(clientesRepositoryProvider).eliminarCliente(id);
  }

  // Paso 2: la base ya lo borró; se quita de la lista en pantalla sin volver
  // a consultar. Tiene que ser inmediato: el Dismissible ya no está.
  void quitarDeLaLista(String id) {
    final actual = state.value;
    if (actual == null) return;
    state = AsyncData([
      for (final c in actual)
        if (c.id != id) c,
    ]);
  }

  // Deshacer: se restaura en la base y se vuelve a consultar, así lo que se
  // ve es lo que de verdad quedó guardado.
  Future<void> restaurar(String id) async {
    await ref.read(clientesRepositoryProvider).restaurarCliente(id);
    ref.invalidateSelf();
  }
}

final clientesProvider = AsyncNotifierProvider<ClientesNotifier, List<Cliente>>(
  ClientesNotifier.new,
  // Riverpod 3 reintenta solo cuando hay error, y eso escondería el estado
  // de error. Lo desactivamos: el usuario decide cuándo reintentar.
  retry: (_, _) => null,
);
