import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_supabase.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/agenda/domain/resultado_llamada.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('actividadDesdeFila lee el cliente anidado y los enums', () {
    final a = actividadDesdeFila(
      {
        'id': 'a1',
        'cliente_id': 'c1',
        'tipo': 'instalacion',
        'estado': 'pendiente',
        'programada_para': '2026-11-04T01:00:00+00:00',
        'nota': null,
        'cliente': {'nombre': 'José Pérez', 'telefono': '4021 7788'},
      },
      {'c1': 3},
    );

    expect(a.cliente, 'José Pérez');
    expect(a.tipo, TipoActividad.instalacion);
    expect(a.estado, EstadoActividad.pendiente);
    expect(a.descripcion, '');
    expect(a.intentosSinRespuesta, 3);
    expect(a.programadaPara, DateTime.utc(2026, 11, 4, 1).toLocal());
  });

  test('actividadDesdeFila lee la nota fija y el último comentario', () {
    final a = actividadDesdeFila({
      'id': 'a1',
      'cliente_id': 'c1',
      'tipo': 'llamada',
      'estado': 'pendiente',
      'programada_para': '2026-11-04T01:00:00+00:00',
      'nota': null,
      'cliente': {
        'nombre': 'María López',
        'telefono': '5512 3456',
        'nota_fija': 'Después de las 5',
        'comentarios': [
          {'texto': 'Espera la quincena', 'creado_en': '2026-11-03T01:00:00Z'},
        ],
      },
    });

    expect(a.notaFija, 'Después de las 5');
    expect(a.ultimoComentario, 'Espera la quincena');
  });

  test('rangoDelDia va de las 00:00 a las 00:00 del día siguiente', () {
    final (desde, hasta) = rangoDelDia(DateTime(2026, 11, 3, 19, 30));

    expect(desde.isUtc, isTrue);
    expect(desde.toLocal(), DateTime(2026, 11, 3));
    expect(hasta.toLocal(), DateTime(2026, 11, 4));
  });

  test('parametrosDeRegistro usa los valores de Postgres', () {
    final p = parametrosDeRegistro(
      RegistroLlamada(
        actividadId: 'a1',
        resultado: ResultadoLlamada.noContesto,
        comentario: '   ',
        siguienteTipo: TipoActividad.llamada,
        siguienteFecha: DateTime(2026, 11, 4, 9),
      ),
    );

    expect(p['p_resultado'], 'no_contesto');
    expect(p['p_comentario'], isNull);
    expect(p['p_siguiente_tipo'], 'llamada');
    expect(p['p_siguiente_fecha'], endsWith('Z'));
  });

  test('parametrosDeRegistro manda p_producto solo si se eligió', () {
    RegistroLlamada con(String? producto) => RegistroLlamada(
      actividadId: 'a1',
      resultado: ResultadoLlamada.interesado,
      productoInteresId: producto,
    );

    expect(parametrosDeRegistro(con('p200'))['p_producto'], 'p200');
    expect(parametrosDeRegistro(con(null)).containsKey('p_producto'), isFalse);
  });

  test('cada ResultadoLlamada existe en el enum de Postgres', () {
    const enPostgres = {
      'no_contesto',
      'no_interesado',
      'interesado',
      'pidio_cotizacion',
      'agendo_visita',
      'compro',
      'numero_equivocado',
      'no_volver_a_llamar',
    };
    expect({for (final r in ResultadoLlamada.values) r.valor}, enPostgres);
  });

  test('traducirErrorActividades da mensajes para personas', () {
    String mensaje(String codigo) => traducirErrorActividades(
      PostgrestException(message: 'técnico', code: codigo),
    ).mensaje;

    expect(mensaje('P0002'), noExiste);
    expect(mensaje('42501'), contains('no permite'));
    expect(mensaje('08006'), sinConexion);
  });
}
