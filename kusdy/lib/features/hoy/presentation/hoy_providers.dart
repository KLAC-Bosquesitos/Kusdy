import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hoy_repository_falso.dart';
import '../domain/hoy_repository.dart';
import '../domain/pendiente_hoy.dart';

// Qué repositorio usa la app. Las pruebas lo reemplazan con overrideWithValue.
final hoyRepositoryProvider = Provider<HoyRepository>((ref) {
  return HoyRepositoryFalso(modo: ModoHoy.desdeEntorno());
});

// Los pendientes de hoy. Para recargar: ref.invalidate(pendientesHoyProvider).
final pendientesHoyProvider = FutureProvider<List<PendienteHoy>>(
  (ref) => ref.watch(hoyRepositoryProvider).obtenerPendientesDeHoy(),
  // Sin reintento automático de Riverpod 3: el usuario decide cuándo reintentar.
  retry: (_, _) => null,
);
