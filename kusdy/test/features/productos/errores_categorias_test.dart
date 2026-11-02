import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/features/productos/data/categorias_repository_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// La base habla en códigos de Postgres; la persona debe leer algo que
// entienda. Estas pruebas no necesitan internet.
void main() {
  PostgrestException error(String codigo) =>
      PostgrestException(message: 'duplicate key value...', code: codigo);

  test('nombre repetido (23505) da un mensaje humano con el nombre', () {
    final e = traducirErrorCategoria(error('23505'), nombre: 'Servicios');
    expect(e.mensaje, 'Ya existe la categoría "Servicios".');
  });

  test('en uso (23503) sugiere archivar', () {
    expect(
      traducirErrorCategoria(error('23503')).mensaje,
      contains('Archívala'),
    );
  });

  test('sin permiso (42501) lo dice claro', () {
    expect(traducirErrorCategoria(error('42501')).mensaje, sinPermiso);
  });

  test('cualquier otro error nunca muestra el texto técnico', () {
    final e = traducirErrorCategoria(error('XX000'));
    expect(e.mensaje, isNot(contains('duplicate')));
    expect(e.mensaje, contains('intenta de nuevo'));
  });
}
