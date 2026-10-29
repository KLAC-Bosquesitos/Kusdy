import 'dart:async';

import '../domain/auth_repository.dart';

// Sesión en memoria para las pruebas de widget: no hay internet ni Supabase.
// Solo acepta el correo y la contraseña de abajo.
class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({this.conSesion = false});

  static const correoValido = 'fredy@kusdy.test';
  static const contrasenaValida = 'kusdy123';

  // Si hay sesión en este momento.
  bool conSesion;
  final _cambios = StreamController<bool>.broadcast();

  @override
  Stream<bool> cambiosDeSesion() async* {
    yield conSesion;
    yield* _cambios.stream;
  }

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (correo.trim() != correoValido || contrasena != contrasenaValida) {
      throw const SesionException('Correo o contraseña incorrectos.');
    }
    _cambiar(true);
  }

  @override
  Future<void> cerrarSesion() async => _cambiar(false);

  void _cambiar(bool conSesion) {
    this.conSesion = conSesion;
    _cambios.add(conSesion);
  }
}
