// Lo que se escribe en el formulario de cliente (crear y editar).
class DatosCliente {
  const DatosCliente({
    required this.nombre,
    required this.telefono,
    this.direccion,
    this.ciudad,
    this.notaFija,
    this.primeraLlamada,
  });

  final String nombre;
  final String telefono;
  final String? direccion;
  final String? ciudad;
  final String? notaFija;

  // Solo al crear: si viene, se agenda la primera llamada.
  final DateTime? primeraLlamada;
}

// Error con un mensaje que se puede mostrar tal cual.
class ClienteException implements Exception {
  const ClienteException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
