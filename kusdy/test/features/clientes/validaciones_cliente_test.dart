import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/clientes/domain/validaciones_cliente.dart';

void main() {
  test('validarNombre pide al menos 3 letras', () {
    expect(validarNombre('  '), isNotNull);
    expect(validarNombre('Al'), isNotNull);
    expect(validarNombre('Ana Gómez'), isNull);
  });

  test('validarTelefono acepta 8 dígitos con espacios, guiones o +502', () {
    expect(validarTelefono('5512 3456'), isNull);
    expect(validarTelefono('5512-3456'), isNull);
    expect(validarTelefono('+502 5512 3456'), isNull);
    expect(validarTelefono('5512 345'), isNotNull);
    expect(validarTelefono(''), isNotNull);
  });

  test('formatearTelefono deja "5512 3456"', () {
    expect(formatearTelefono('55123456'), '5512 3456');
    expect(formatearTelefono('+502 5512-3456'), '5512 3456');
    expect(formatearTelefono('123'), '123');
  });

  test('primeraLlamadaEn: a las 9:00 del día elegido', () {
    final hoy = DateTime(2026, 11, 30, 18);
    expect(primeraLlamadaEn(1, hoy), DateTime(2026, 12, 1, 9));
    expect(primeraLlamadaEn(0, hoy), DateTime(2026, 11, 30, 9));
  });
}
