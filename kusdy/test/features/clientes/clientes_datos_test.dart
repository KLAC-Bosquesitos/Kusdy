import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_supabase.dart';
import 'package:kusdy/features/clientes/data/comentarios_repository_supabase.dart';
import 'package:kusdy/features/clientes/domain/datos_cliente.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Fila como la devuelve la vista clientes_resumen.
Map<String, dynamic> fila({Map<String, dynamic> cambios = const {}}) => {
  'id': 'c1',
  'nombre': 'María López',
  'telefono': '5512 3456',
  'direccion': null,
  'ciudad': 'Quetzaltenango',
  'nota_fija': null,
  'creado_en': '2026-11-01T16:00:00+00:00',
  'producto_interes_id': 'p1',
  'ultimo_contacto': null,
  'proxima_llamada': '2026-11-04T15:00:00+00:00',
  'no_contesto': true,
  'intentos_sin_respuesta': 3,
  ...cambios,
};

void main() {
  group('clienteDesdeFila', () {
    test('convierte la fila con fechas y producto', () {
      final c = clienteDesdeFila(fila(), {'p1': 'Calentador 200 L'});

      expect(c.nombre, 'María López');
      expect(c.producto, 'Calentador 200 L');
      expect(c.registradoEl, DateTime.utc(2026, 11, 1, 16).toLocal());
      expect(c.proximaLlamada!.isUtc, isFalse);
      expect(c.noContesto, isTrue);
      expect(c.intentosSinRespuesta, 3);
    });

    test('acepta nulos sin romperse', () {
      final c = clienteDesdeFila(
        fila(
          cambios: {
            'producto_interes_id': null,
            'proxima_llamada': null,
            'no_contesto': null,
            'intentos_sin_respuesta': null,
          },
        ),
      );

      expect(c.producto, isNull);
      expect(c.proximaLlamada, isNull);
      expect(c.noContesto, isFalse);
      expect(c.intentosSinRespuesta, 0);
    });
  });

  test('filaDesdeDatos guarda vacíos como null y quita espacios', () {
    final f = filaDesdeDatos(
      const DatosCliente(
        nombre: '  Ana Gómez ',
        telefono: '3390 1122',
        ciudad: '   ',
        notaFija: 'Llamar tarde',
      ),
    );

    expect(f['nombre'], 'Ana Gómez');
    expect(f['ciudad'], isNull);
    expect(f['direccion'], isNull);
    expect(f['nota_fija'], 'Llamar tarde');
  });

  test('filaDesdeDatos guarda el producto de interés', () {
    const datos = DatosCliente(nombre: 'Ana', telefono: '3390 1122');
    expect(filaDesdeDatos(datos)['producto_interes_id'], isNull);
    final conProducto = filaDesdeDatos(
      const DatosCliente(
        nombre: 'Ana',
        telefono: '3390 1122',
        productoInteresId: 'p200',
      ),
    );
    expect(conProducto['producto_interes_id'], 'p200');
  });

  test('textoParaBuscar quita lo que rompe el filtro .or()', () {
    expect(textoParaBuscar(' López, María (hija) '), 'López  María  hija');
    expect(textoParaBuscar('   '), '');
  });

  test('rangoDelMes va del día 1 al día 1 del mes siguiente', () {
    final (desde, hasta) = rangoDelMes(DateTime(2026, 12));

    expect(desde.toLocal(), DateTime(2026, 12));
    expect(hasta.toLocal(), DateTime(2027));
  });

  test('traducirErrorClientes da mensajes para personas', () {
    String mensaje(String codigo) => traducirErrorClientes(
      PostgrestException(message: 'técnico', code: codigo),
    ).mensaje;

    expect(mensaje('42501'), contains('no permite'));
    expect(mensaje('23502'), contains('obligatorios'));
    expect(mensaje('XX000'), sinConexion);
  });

  test('comentarioDesdeFila marca editados y tolera autor oculto', () {
    final c = comentarioDesdeFila({
      'id': 'm1',
      'cliente_id': 'c1',
      'texto': 'Pidió cotización',
      'creado_en': '2026-11-02T20:00:00+00:00',
      'editado_en': '2026-11-02T21:00:00+00:00',
      'autor': null,
    });

    expect(c.editado, isTrue);
    expect(c.autor, 'Otro usuario');
  });
}
