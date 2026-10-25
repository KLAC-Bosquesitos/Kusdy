// Cliente o prospecto de Energica Solar.
// Modelo mínimo para la lista; los campos definitivos salen de la vista
// clientes_resumen cuando se conecte Supabase.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.registradoEl,
    this.producto,
  });

  final String id;
  final String nombre;
  final String telefono;

  // Fecha de registro (clientes.creado_en). Fredy filtra por mes de registro.
  final DateTime registradoEl;

  // Producto de interés (calentador, panel...), sale de los bocetos 5 y 6.
  final String? producto;
}
