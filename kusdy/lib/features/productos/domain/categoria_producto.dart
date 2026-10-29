// Categoría del catálogo (Calentador solar por gravedad, Presurizado,
// Servicios...). Tabla categorias_producto de Supabase (migración 4).
// La administran el jefe de sucursal, el supervisor y el gerente general.
class CategoriaProducto {
  const CategoriaProducto({
    required this.id,
    required this.nombre,
    this.archivada = false,
    this.productos = 0,
  });

  final String id;
  final String nombre;

  // Archivada = ya no se ofrece al crear productos, pero sus productos y su
  // historia se conservan. Es la salida cuando no se puede borrar.
  final bool archivada;

  // Cuántos productos apuntan a esta categoría. Si hay alguno, está en uso.
  final int productos;

  bool get enUso => productos > 0;
}

// Error con un mensaje para personas. La pantalla lo muestra tal cual; nunca
// muestra el texto de un error de la base.
class CategoriaException implements Exception {
  const CategoriaException(this.mensaje);

  // Los mensajes de las reglas se escriben una sola vez, aquí, para que el
  // repositorio en memoria y el de Supabase digan exactamente lo mismo.
  factory CategoriaException.repetida(String nombre) =>
      CategoriaException('Ya existe la categoría "$nombre".');

  factory CategoriaException.enUso(int productos) => CategoriaException(
    productos == 1
        ? 'Tiene 1 producto. Archívala para dejar de verla.'
        : 'Tiene $productos productos. Archívala para dejar de verla.',
  );

  final String mensaje;

  @override
  String toString() => mensaje;
}

// Limpia el nombre antes de guardarlo. Así "  Paneles " y "Paneles" son el
// mismo nombre para la regla de nombres repetidos.
String nombreCategoriaValido(String nombre) {
  final limpio = nombre.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (limpio.isEmpty) {
    throw const CategoriaException('Escribe el nombre de la categoría.');
  }
  return limpio;
}
