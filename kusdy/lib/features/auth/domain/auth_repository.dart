// Contrato de la sesión. La pantalla de login y la puerta de la app solo
// conocen esto; Supabase queda escondido en data/.
abstract class AuthRepository {
  // true si hay sesión. Emite al empezar (la sesión guardada en el teléfono)
  // y cada vez que alguien entra o sale.
  Stream<bool> cambiosDeSesion();

  // Lanza SesionException con un mensaje para personas si no se pudo.
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}

// Error de inicio de sesión con un mensaje que se puede mostrar tal cual.
class SesionException implements Exception {
  const SesionException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
