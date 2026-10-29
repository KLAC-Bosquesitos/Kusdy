import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/estado_cargando.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import 'shell.dart';

// Sin sesión no se ve nada de la app: la base de datos (RLS) no le daría
// datos a nadie sin sesión. Con sesión, la barra de pestañas de siempre.
class PuertaSesion extends ConsumerWidget {
  const PuertaSesion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionProvider);
    return sesion.when(
      data: (conSesion) => conSesion ? const KusdyShell() : const LoginScreen(),
      loading: () =>
          const Scaffold(body: EstadoCargando(mensaje: 'Abriendo Kusdy…')),
      // Si no se pudo leer la sesión guardada, se pide entrar de nuevo.
      error: (_, _) => const LoginScreen(),
    );
  }
}
