import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/fechas.dart';
import '../../../core/widgets/estado_cargando.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../domain/actividad_agenda.dart';
import '../domain/filtro_agenda.dart';
import 'agenda_providers.dart';

// Agenda por día (punto 6 de la retro). Filtro por día y tipo, los 4 estados
// de una lectura, el vacío según el filtro y cancelar deslizando con Deshacer.
class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividades = ref.watch(agendaProvider);
    final filtro = ref.watch(filtroAgendaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
      ),
      body: Column(
        children: [
          const _BarraFiltros(),
          // Al cambiar de día se queda la lista anterior y aparece esta
          // barrita, en vez de borrar la pantalla.
          if (actividades.isLoading && actividades.hasValue)
            const LinearProgressIndicator(minHeight: 3)
          else
            const SizedBox(height: 3),
          Expanded(
            child: actividades.when(
              skipLoadingOnReload: true,
              loading: () =>
                  const EstadoCargando(mensaje: 'Cargando tu agenda…'),
              error: (_, _) => EstadoError(
                mensaje:
                    'No pudimos cargar tu agenda.\n'
                    'Revisa tu conexión a internet.',
                onReintentar: () => ref.invalidate(agendaProvider),
              ),
              data: (lista) => lista.isEmpty
                  ? _vacio(ref, filtro)
                  : _ListaActividades(actividades: lista),
            ),
          ),
        ],
      ),
    );
  }

  // Vacío según el filtro: si hay un tipo elegido, se ofrece ver todos;
  // si no, se ofrece ir al siguiente día.
  Widget _vacio(WidgetRef ref, FiltroAgenda filtro) {
    final notifier = ref.read(filtroAgendaProvider.notifier);
    final tipo = filtro.tipo;
    if (tipo != null) {
      return EstadoVacio(
        icono: Icons.search_off,
        mensaje: 'No tienes ${tipo.plural.toLowerCase()} este día.',
        textoAccion: 'Ver todos los tipos',
        iconoAccion: Icons.filter_alt_off_outlined,
        onAccion: () => notifier.elegirTipo(null),
      );
    }
    return EstadoVacio(
      icono: Icons.event_available_outlined,
      mensaje: 'No tienes actividades este día.',
      textoAccion: 'Ver el día siguiente',
      iconoAccion: Icons.arrow_forward,
      onAccion: notifier.diaSiguiente,
    );
  }
}

// Día ("< Hoy · jueves 22 de octubre >") y tipo. Solo cambia el filtro; la
// lista reacciona sola.
class _BarraFiltros extends ConsumerWidget {
  const _BarraFiltros();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroAgendaProvider);
    final notifier = ref.read(filtroAgendaProvider.notifier);
    final esHoy = mismoDia(filtro.dia, DateTime.now());

    return Container(
      color: KusdyColors.superficie,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Día anterior',
                iconSize: 32,
                icon: const Icon(Icons.chevron_left),
                onPressed: notifier.diaAnterior,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _nombreRelativo(filtro.dia),
                      key: const Key('agenda-dia'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: KusdyColors.texto,
                      ),
                    ),
                    if (!esHoy)
                      TextButton(
                        onPressed: notifier.irAHoy,
                        child: const Text(
                          'Volver a hoy',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Día siguiente',
                iconSize: 32,
                icon: const Icon(Icons.chevron_right),
                onPressed: notifier.diaSiguiente,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tipo de actividad',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TipoActividad?>(
                  key: const Key('filtro-tipo'),
                  value: filtro.tipo,
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: 17,
                    color: KusdyColors.texto,
                  ),
                  onChanged: notifier.elegirTipo,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos los tipos'),
                    ),
                    for (final tipo in TipoActividad.values)
                      DropdownMenuItem(value: tipo, child: Text(tipo.plural)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// "Hoy · jueves 22 de octubre", "Mañana · …", "Ayer · …" o solo la fecha.
String _nombreRelativo(DateTime dia) {
  final hoy = soloDia(DateTime.now());
  final diferencia = (dia.difference(hoy).inHours / 24).round();
  final fecha = diaLargo(dia);
  return switch (diferencia) {
    0 => 'Hoy · $fecha',
    1 => 'Mañana · $fecha',
    -1 => 'Ayer · $fecha',
    _ => '${fecha[0].toUpperCase()}${fecha.substring(1)}',
  };
}

class _ListaActividades extends ConsumerWidget {
  const _ListaActividades({required this.actividades});

  final List<ActividadAgenda> actividades;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: actividades.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final actividad = actividades[i];
        return Dismissible(
          // La key es el id de la actividad, nunca la posición: al cancelar
          // una, las de abajo suben de lugar pero siguen siendo las mismas.
          key: ValueKey(actividad.id),
          direction: DismissDirection.endToStart,
          background: const _FondoCancelar(),
          confirmDismiss: (_) => _cancelarEnBase(context, ref, actividad),
          onDismissed: (_) => _avisarCancelada(context, ref, actividad),
          child: _TarjetaActividad(actividad: actividad),
        );
      },
    );
  }

  // Primero se cancela en la base. Devolver false hace que la fila regrese.
  Future<bool> _cancelarEnBase(
    BuildContext context,
    WidgetRef ref,
    ActividadAgenda actividad,
  ) async {
    final aviso = ScaffoldMessenger.of(context);
    try {
      await ref.read(agendaProvider.notifier).cancelarEnBase(actividad.id);
      return true;
    } catch (_) {
      aviso
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo cancelar la actividad. Revisa tu conexión.',
            ),
          ),
        );
      return false;
    }
  }

  // Ya se canceló en la base: se quita de la pantalla y se ofrece Deshacer.
  void _avisarCancelada(
    BuildContext context,
    WidgetRef ref,
    ActividadAgenda actividad,
  ) {
    final aviso = ScaffoldMessenger.of(context);
    // Se guarda el contenedor y no el ref: si era la última actividad, esta
    // lista desaparece y su ref ya no se puede usar cuando tocan Deshacer.
    final contenedor = ProviderScope.containerOf(context);
    ref.read(agendaProvider.notifier).quitarDeLaLista(actividad.id);

    aviso
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Se canceló: ${actividad.tipo.texto} con ${actividad.cliente}.',
          ),
          duration: const Duration(seconds: 6),
          // Con una acción, Flutter deja el aviso fijo si no se indica esto.
          persist: false,
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              try {
                await contenedor
                    .read(agendaProvider.notifier)
                    .reactivar(actividad.id);
              } catch (_) {
                aviso.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se pudo recuperar la actividad. Intenta de nuevo.',
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

class _FondoCancelar extends StatelessWidget {
  const _FondoCancelar();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: KusdyColors.vencido,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_outlined, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Cancelar',
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

class _TarjetaActividad extends StatelessWidget {
  const _TarjetaActividad({required this.actividad});

  final ActividadAgenda actividad;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: KusdyColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: KusdyColors.borde),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(
          hora(actividad.programadaPara),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: KusdyColors.primario,
          ),
        ),
        title: Text(
          actividad.cliente,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${actividad.tipo.texto} · ${actividad.descripcion}\n'
          '${actividad.telefono}',
          style: const TextStyle(
            fontSize: 15,
            color: KusdyColors.textoSecundario,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
