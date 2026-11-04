import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/cliente.dart';
import '../domain/clientes_repository.dart';
import '../domain/datos_cliente.dart';
import '../domain/filtro_clientes.dart';

// Clientes en Supabase. Se lee de la vista clientes_resumen y se escribe en
// la tabla clientes. RLS decide qué clientes ve cada quien.
class ClientesRepositorySupabase implements ClientesRepository {
  ClientesRepositorySupabase(this._db);

  final SupabaseClient _db;

  static const _columnas =
      'id, nombre, telefono, direccion, ciudad, nota_fija, creado_en, '
      'producto_interes_id, ultimo_contacto, proxima_llamada, no_contesto, '
      'intentos_sin_respuesta';

  String get _yo => _db.auth.currentUser!.id;

  @override
  Future<List<Cliente>> obtenerClientes(FiltroClientes filtro) {
    return _intentar(() async {
      var consulta = _db.from('clientes_resumen').select(_columnas);

      final texto = textoParaBuscar(filtro.texto);
      if (texto.isNotEmpty) {
        consulta = consulta.or('nombre.ilike.%$texto%,telefono.ilike.%$texto%');
      }
      final mes = filtro.mes;
      if (mes != null) {
        final (desde, hasta) = rangoDelMes(mes);
        consulta = consulta
            .gte('creado_en', desde.toIso8601String())
            .lt('creado_en', hasta.toIso8601String());
      }

      final filas = await consulta.order('creado_en', ascending: false);
      final productos = await _nombresDeProductos(filas);
      return [for (final f in filas) clienteDesdeFila(f, productos)];
    });
  }

  @override
  Future<Cliente> obtenerCliente(String id) {
    return _intentar(() async {
      final fila = await _db
          .from('clientes_resumen')
          .select(_columnas)
          .eq('id', id)
          .maybeSingle();
      if (fila == null) throw const ClienteException(noExiste);
      return clienteDesdeFila(fila, await _nombresDeProductos([fila]));
    });
  }

  @override
  Future<String> crearCliente(DatosCliente datos) {
    return _intentar(() async {
      final fila = await _db
          .from('clientes')
          .insert({
            ...filaDesdeDatos(datos),
            'vendedor_id': _yo,
            'creado_por': _yo,
          })
          .select('id')
          .single();
      final id = fila['id'] as String;

      final primera = datos.primeraLlamada;
      if (primera != null) {
        await _db.from('actividades').insert({
          'cliente_id': id,
          'usuario_id': _yo,
          'creado_por': _yo,
          'tipo': 'llamada',
          'programada_para': primera.toUtc().toIso8601String(),
        });
      }
      return id;
    });
  }

  @override
  Future<void> actualizarCliente(String id, DatosCliente datos) {
    return _cambiar(id, filaDesdeDatos(datos));
  }

  @override
  Future<void> eliminarCliente(String id) {
    return _cambiar(id, {
      'eliminado_en': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> restaurarCliente(String id) {
    return _cambiar(id, {'eliminado_en': null});
  }

  // Con RLS, si no hay permiso no hay error: solo 0 filas cambiadas.
  Future<void> _cambiar(String id, Map<String, dynamic> cambios) {
    return _intentar(() async {
      final cambiadas = await _db
          .from('clientes')
          .update(cambios)
          .eq('id', id)
          .select('id');
      if (cambiadas.isEmpty) throw const ClienteException(noExiste);
    });
  }

  // Nombre del producto de interés, en una sola consulta para toda la lista.
  Future<Map<String, String>> _nombresDeProductos(
    List<Map<String, dynamic>> filas,
  ) async {
    final ids = {
      for (final f in filas)
        if (f['producto_interes_id'] != null)
          f['producto_interes_id'] as String,
    };
    if (ids.isEmpty) return {};
    final productos = await _db
        .from('productos')
        .select('id, nombre')
        .inFilter('id', ids.toList());
    return {
      for (final p in productos) p['id'] as String: p['nombre'] as String,
    };
  }
}

const noExiste = 'Ese cliente ya no existe o no tienes permiso para verlo.';
const sinConexion =
    'No pudimos guardar. Revisa tu conexión e intenta de nuevo.';

Future<T> _intentar<T>(Future<T> Function() accion) async {
  try {
    return await accion();
  } on ClienteException {
    rethrow;
  } on PostgrestException catch (e) {
    throw traducirErrorClientes(e);
  } catch (_) {
    throw const ClienteException(sinConexion);
  }
}

// Códigos estándar de Postgres.
ClienteException traducirErrorClientes(PostgrestException e) {
  return switch (e.code) {
    '42501' => const ClienteException(
      'Tu puesto no permite cambiar este cliente.',
    ),
    '23502' || '23514' => const ClienteException(
      'Faltan datos: el nombre y el teléfono son obligatorios.',
    ),
    _ => const ClienteException(sinConexion),
  };
}

// Las comas y paréntesis romperían el filtro .or() de PostgREST.
String textoParaBuscar(String texto) =>
    texto.trim().replaceAll(RegExp(r'[,()%*\\]'), ' ').trim();

// Del día 1 del mes (00:00 local) al día 1 del siguiente.
(DateTime, DateTime) rangoDelMes(DateTime mes) {
  final desde = DateTime(mes.year, mes.month);
  final hasta = DateTime(mes.year, mes.month + 1);
  return (desde.toUtc(), hasta.toUtc());
}

Cliente clienteDesdeFila(
  Map<String, dynamic> f, [
  Map<String, String> productos = const {},
]) {
  DateTime? fecha(String columna) {
    final valor = f[columna] as String?;
    return valor == null ? null : DateTime.parse(valor).toLocal();
  }

  return Cliente(
    id: f['id'] as String,
    nombre: f['nombre'] as String,
    telefono: f['telefono'] as String,
    direccion: f['direccion'] as String?,
    ciudad: f['ciudad'] as String?,
    notaFija: f['nota_fija'] as String?,
    registradoEl: fecha('creado_en')!,
    producto: productos[f['producto_interes_id']],
    ultimoContacto: fecha('ultimo_contacto'),
    proximaLlamada: fecha('proxima_llamada'),
    noContesto: f['no_contesto'] as bool? ?? false,
    intentosSinRespuesta: (f['intentos_sin_respuesta'] as num?)?.toInt() ?? 0,
  );
}

// Campos vacíos se guardan como null, no como ''.
Map<String, dynamic> filaDesdeDatos(DatosCliente d) {
  String? limpio(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();
  return {
    'nombre': d.nombre.trim(),
    'telefono': d.telefono.trim(),
    'direccion': limpio(d.direccion),
    'ciudad': limpio(d.ciudad),
    'nota_fija': limpio(d.notaFija),
  };
}
