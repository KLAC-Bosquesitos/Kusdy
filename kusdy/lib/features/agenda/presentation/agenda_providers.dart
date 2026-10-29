import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/fechas.dart';
import '../data/agenda_repository_falso.dart';
import '../domain/actividad_agenda.dart';
import '../domain/agenda_repository.dart';
import '../domain/filtro_agenda.dart';

// Qué repositorio usa la app. Las pruebas lo reemplazan con overrideWithValue.
final agendaRepositoryProvider = Provider<AgendaRepository>((ref) {
  return AgendaRepositoryFalso(modo: ModoAgenda.desdeEntorno());
});

// El filtro activo. Empieza en hoy, con todos los tipos. Cada método
// reemplaza el filtro por uno nuevo.
class FiltroAgendaNotifier extends Notifier<FiltroAgenda> {
  @override
  FiltroAgenda build() => FiltroAgenda(dia: soloDia(DateTime.now()));

  void diaAnterior() => _irA(state.dia.subtract(const Duration(days: 1)));

  void diaSiguiente() => _irA(state.dia.add(const Duration(days: 1)));

  void irAHoy() => _irA(DateTime.now());

  void elegirTipo(TipoActividad? tipo) {
    state = FiltroAgenda(dia: state.dia, tipo: tipo);
  }

  // soloDia también corrige el cambio de horario: siempre queda a las 00:00.
  void _irA(DateTime dia) {
    state = FiltroAgenda(dia: soloDia(dia), tipo: state.tipo);
  }
}

final filtroAgendaProvider =
    NotifierProvider<FiltroAgendaNotifier, FiltroAgenda>(
      FiltroAgendaNotifier.new,
    );

// Las actividades del día. Hace watch del filtro: cuando el filtro cambia,
// build() se vuelve a ejecutar solo, sin botón de "recargar".
// Para recargar a mano: ref.invalidate(agendaProvider).
class AgendaNotifier extends AsyncNotifier<List<ActividadAgenda>> {
  @override
  Future<List<ActividadAgenda>> build() {
    final filtro = ref.watch(filtroAgendaProvider);
    return ref.watch(agendaRepositoryProvider).obtenerActividades(filtro);
  }

  // Paso 1: primero se cancela en la base. Si falla, lanza el error y la
  // pantalla deja la fila donde estaba.
  Future<void> cancelarEnBase(String id) {
    return ref.read(agendaRepositoryProvider).cancelarActividad(id);
  }

  // Paso 2: la base ya la canceló; se quita de la lista en pantalla sin
  // volver a consultar. Tiene que ser inmediato: el Dismissible ya no está.
  void quitarDeLaLista(String id) {
    final actual = state.value;
    if (actual == null) return;
    state = AsyncData([
      for (final a in actual)
        if (a.id != id) a,
    ]);
  }

  // Deshacer: vuelve a pendiente en la base y se consulta de nuevo.
  Future<void> reactivar(String id) async {
    await ref.read(agendaRepositoryProvider).reactivarActividad(id);
    ref.invalidateSelf();
  }
}

final agendaProvider =
    AsyncNotifierProvider<AgendaNotifier, List<ActividadAgenda>>(
      AgendaNotifier.new,
      // Sin reintento automático de Riverpod 3: el usuario decide cuándo
      // reintentar.
      retry: (_, _) => null,
    );
