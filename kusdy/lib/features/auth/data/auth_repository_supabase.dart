import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repository.dart';

// HU-01 · Iniciar sesión con correo y contraseña. Los usuarios los crea un
// jefe, supervisor o gerente (no hay "registrarse" en la app).
class AuthRepositorySupabase implements AuthRepository {
  AuthRepositorySupabase(this._auth);

  final GoTrueClient _auth;

  @override
  Stream<bool> cambiosDeSesion() =>
      _auth.onAuthStateChange.map((estado) => estado.session != null);

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _auth.signInWithPassword(
        email: correo.trim(),
        password: contrasena,
      );
    } on AuthRetryableFetchException {
      throw const SesionException(
        'No hay conexión. Revisa tu internet e intenta de nuevo.',
      );
    } on AuthException catch (e) {
      // Nunca se muestra e.message: viene en inglés y es técnico.
      if (e.code == 'invalid_credentials' || e.statusCode == '400') {
        throw const SesionException('Correo o contraseña incorrectos.');
      }
      throw const SesionException(
        'No pudimos iniciar sesión. Intenta de nuevo.',
      );
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();
}
