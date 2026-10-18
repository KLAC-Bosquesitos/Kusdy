// Cliente o prospecto de Energica Solar.
// Modelo mínimo para la lista; los campos definitivos se confirman cuando se
// retome el diseño de la base de datos.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.producto,
  });

  final String id;
  final String nombre;
  final String telefono;

  // Producto de interés (calentador, panel...), sale de los bocetos 5 y 6.
  final String? producto;
}
