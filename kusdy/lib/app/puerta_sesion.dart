import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/estado_cargando.dart';
import '../features/agenda/presentation/agenda_providers.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/clientes/presentation/cliente_detalle_providers.dart';
import '../features/clientes/presentation/clientes_providers.dart';
import '../features/hoy/presentation/hoy_providers.dart';
import '../features/productos/presentation/categorias_providers.dart';
import 'shell.dart';

// Sin sesión no se ve nada de la app: la base de datos (RLS) no le daría
// datos a nadie sin sesión. Con sesión, la barra de pestañas de siempre.
class PuertaSesion extends ConsumerWidget {
  const PuertaSesion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Al entrar se olvida lo cargado: si no, otra cuenta vería los datos de
    // la anterior hasta cerrar la app.
    ref.listen(sesionProvider, (antes, ahora) {
      if (antes?.value == false && ahora.value == true) {
        olvidarDatosDeSesion(ref);
      }
    });
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

void olvidarDatosDeSesion(WidgetRef ref) {
  ref
    ..invalidate(pendientesHoyProvider)
    ..invalidate(agendaProvider)
    ..invalidate(filtroAgendaProvider)
    ..invalidate(clientesProvider)
    ..invalidate(filtroClientesProvider)
    ..invalidate(clienteProvider)
    ..invalidate(comentariosProvider)
    ..invalidate(categoriasProvider);
}
