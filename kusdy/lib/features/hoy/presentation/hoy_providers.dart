import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agenda/domain/actividad_agenda.dart';
import '../../agenda/presentation/agenda_providers.dart';

// Pendientes de hoy y vencidos. Para recargar: ref.invalidate(pendientesHoyProvider).
final pendientesHoyProvider = FutureProvider<List<ActividadAgenda>>(
  (ref) => ref.watch(actividadesRepositoryProvider).pendientesDeHoy(),
  // Sin reintento automático: el usuario decide cuándo reintentar.
  retry: (_, _) => null,
);
