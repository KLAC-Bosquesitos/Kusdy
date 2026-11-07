import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/fechas.dart';
import '../domain/actividad_agenda.dart';
import '../domain/actividades_repository.dart';
import '../domain/filtro_agenda.dart';
import '../domain/resultado_llamada.dart';

// Actividades en Supabase. Hoy y Agenda muestran solo las mías; RLS impide
// además ver o cambiar las de otro vendedor.
class ActividadesRepositorySupabase implements ActividadesRepository {
  ActividadesRepositorySupabase(this._db);

  final SupabaseClient _db;

  // !inner: si el cliente fue eliminado, su actividad no se trae.
  static const _columnas =
      'id, cliente_id, tipo, estado, programada_para, nota, '
      'cliente:clientes!inner(nombre, telefono, nota_fija, eliminado_en, '
      'comentarios(texto, creado_en))';

  static const _comentarios = 'cliente.comentarios';

  String get _yo => _db.auth.currentUser!.id;

  @override
  Future<List<ActividadAgenda>> pendientesDeHoy() {
    return _leer(() {
      final (_, manana) = rangoDelDia(DateTime.now());
      return _porHora(
        _db
            .from('actividades')
            .select(_columnas)
            .eq('usuario_id', _yo)
            .eq('estado', 'pendiente')
            .isFilter('cliente.eliminado_en', null)
            .lt('programada_para', manana.toIso8601String()),
      );
    });
  }

  @override
  Future<List<ActividadAgenda>> obtenerActividades(FiltroAgenda filtro) {
    return _leer(() {
      final (desde, hasta) = rangoDelDia(filtro.dia);
      var consulta = _db
          .from('actividades')
          .select(_columnas)
          .eq('usuario_id', _yo)
          .neq('estado', 'cancelada')
          .isFilter('cliente.eliminado_en', null)
          .gte('programada_para', desde.toIso8601String())
          .lt('programada_para', hasta.toIso8601String());
      final tipo = filtro.tipo;
      if (tipo != null) consulta = consulta.eq('tipo', tipo.name);
      return _porHora(consulta);
    });
  }

  @override
  Future<void> cancelarActividad(String id) =>
      _cambiar(id, {'estado': 'cancelada'});

  @override
  Future<void> reactivarActividad(String id) =>
      _cambiar(id, {'estado': 'pendiente'});

  @override
  Future<void> reagendar(String id, DateTime nuevaFecha) =>
      _cambiar(id, {'programada_para': nuevaFecha.toUtc().toIso8601String()});

  @override
  Future<void> registrarResultado(RegistroLlamada registro) async {
    try {
      await _db.rpc(
        'registrar_resultado_llamada',
        params: parametrosDeRegistro(registro),
      );
    } on PostgrestException catch (e) {
      throw traducirErrorActividades(e);
    } catch (_) {
      throw const ActividadException(sinConexion);
    }
  }

  // Por hora y, de cada cliente, solo su comentario más reciente.
  PostgrestTransformBuilder<PostgrestList> _porHora(
    PostgrestFilterBuilder<PostgrestList> consulta,
  ) {
    return consulta
        .order('programada_para')
        .order('creado_en', ascending: false, referencedTable: _comentarios)
        .limit(1, referencedTable: _comentarios);
  }

  Future<List<ActividadAgenda>> _leer(
    Future<List<Map<String, dynamic>>> Function() consulta,
  ) async {
    final filas = await consulta();
    final intentos = await _intentosSinRespuesta(filas);
    return [for (final f in filas) actividadDesdeFila(f, intentos)];
  }

  // Con RLS, si no hay permiso no hay error: solo 0 filas cambiadas.
  Future<void> _cambiar(String id, Map<String, dynamic> cambios) async {
    try {
      final cambiadas = await _db
          .from('actividades')
          .update(cambios)
          .eq('id', id)
          .select('id');
      if (cambiadas.isEmpty) throw const ActividadException(noExiste);
    } on PostgrestException catch (e) {
      throw traducirErrorActividades(e);
    }
  }

  // Para el aviso de "Van 3 llamadas sin respuesta", en una sola consulta.
  Future<Map<String, int>> _intentosSinRespuesta(
    List<Map<String, dynamic>> filas,
  ) async {
    final ids = {for (final f in filas) f['cliente_id'] as String};
    if (ids.isEmpty) return {};
    final resumen = await _db
        .from('clientes_resumen')
        .select('id, intentos_sin_respuesta')
        .inFilter('id', ids.toList());
    return {
      for (final r in resumen)
        r['id'] as String: (r['intentos_sin_respuesta'] as num).toInt(),
    };
  }
}

const noExiste = 'Esa actividad ya no existe o ya se registró.';
const sinConexion =
    'No pudimos guardar. Revisa tu conexión e intenta de nuevo.';

ActividadException traducirErrorActividades(PostgrestException e) {
  return switch (e.code) {
    // La función avisa con P0002 si ya no está pendiente o no es tuya.
    'P0002' => const ActividadException(noExiste),
    '42501' => const ActividadException(
      'Tu puesto no permite cambiar esta actividad.',
    ),
    _ => const ActividadException(sinConexion),
  };
}

// El día del teléfono (Guatemala) convertido a UTC, que es como guarda la base.
// Sin esto, una llamada de las 7 p. m. caería en el día siguiente.
(DateTime, DateTime) rangoDelDia(DateTime dia) {
  final desde = soloDia(dia);
  final hasta = DateTime(desde.year, desde.month, desde.day + 1);
  return (desde.toUtc(), hasta.toUtc());
}

Map<String, dynamic> parametrosDeRegistro(RegistroLlamada r) {
  final comentario = r.comentario?.trim();
  return {
    'p_actividad': r.actividadId,
    'p_resultado': r.resultado.valor,
    'p_comentario': (comentario == null || comentario.isEmpty)
        ? null
        : comentario,
    'p_siguiente_tipo': r.siguienteTipo?.name,
    'p_siguiente_fecha': r.siguienteFecha?.toUtc().toIso8601String(),
    // Solo si se eligió: así no cambia el producto que ya tenía.
    if (r.productoInteresId != null) 'p_producto': r.productoInteresId,
  };
}

ActividadAgenda actividadDesdeFila(
  Map<String, dynamic> f, [
  Map<String, int> intentos = const {},
]) {
  final cliente = f['cliente'] as Map<String, dynamic>;
  final comentarios = cliente['comentarios'] as List<dynamic>? ?? const [];
  return ActividadAgenda(
    id: f['id'] as String,
    clienteId: f['cliente_id'] as String,
    cliente: cliente['nombre'] as String,
    telefono: cliente['telefono'] as String,
    tipo: TipoActividad.values.byName(f['tipo'] as String),
    estado: EstadoActividad.values.byName(f['estado'] as String),
    programadaPara: DateTime.parse(f['programada_para'] as String).toLocal(),
    descripcion: f['nota'] as String? ?? '',
    intentosSinRespuesta: intentos[f['cliente_id']] ?? 0,
    notaFija: cliente['nota_fija'] as String?,
    ultimoComentario: comentarios.isEmpty
        ? null
        : (comentarios.first as Map<String, dynamic>)['texto'] as String,
  );
}
