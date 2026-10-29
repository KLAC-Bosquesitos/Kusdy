import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository_supabase.dart';
import '../domain/auth_repository.dart';

// Qué repositorio de sesión usa la app. Supabase.instance solo se toca cuando
// alguien lee este provider: las pruebas lo reemplazan con
// overrideWithValue(AuthRepositoryFalso()) y nunca inicializan Supabase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositorySupabase(Supabase.instance.client.auth);
});

// ¿Hay sesión? La puerta de la app lo escucha: al entrar o salir, cambia
// de pantalla sola.
final sesionProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).cambiosDeSesion();
});
