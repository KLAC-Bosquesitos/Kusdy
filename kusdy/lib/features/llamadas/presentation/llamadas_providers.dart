import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agenda/domain/resultado_llamada.dart';
import '../../agenda/presentation/agenda_providers.dart';
import '../../hoy/presentation/hoy_providers.dart';

// Estado de "¿Qué pasó?" y "Mover": guarda con el repositorio y después
// recarga Hoy y Agenda, para que se vea lo que de verdad quedó guardado.
class Seguimiento {
  Seguimiento(this._ref);

  final Ref _ref;

  Future<void> registrar(RegistroLlamada registro) async {
    await _ref.read(actividadesRepositoryProvider).registrarResultado(registro);
    _recargar();
  }

  Future<void> reagendar(String actividadId, DateTime fecha) async {
    await _ref
        .read(actividadesRepositoryProvider)
        .reagendar(actividadId, fecha);
    _recargar();
  }

  void _recargar() {
    _ref
      ..invalidate(pendientesHoyProvider)
      ..invalidate(agendaProvider);
  }
}

final seguimientoProvider = Provider<Seguimiento>(Seguimiento.new);
