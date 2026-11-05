import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/app/app.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_falso.dart';
import 'package:kusdy/features/agenda/domain/actividad_agenda.dart';
import 'package:kusdy/features/auth/data/auth_repository_falso.dart';
import 'package:kusdy/features/auth/presentation/auth_providers.dart';
import 'package:kusdy/features/auth/presentation/login_screen.dart';

import '../helpers/repositorios_falsos.dart';

// Simula dos cuentas: la primera no tiene llamadas, la segunda sí.
class CuentaQueCambia extends ActividadesRepositoryFalso {
  CuentaQueCambia() : super(demora: Duration.zero);

  var sinActividades = true;

  @override
  Future<List<ActividadAgenda>> pendientesDeHoy() async =>
      sinActividades ? [] : super.pendientesDeHoy();
}

void main() {
  testWidgets('al cambiar de cuenta, Hoy carga los datos de la nueva', (
    tester,
  ) async {
    final auth = AuthRepositoryFalso(conSesion: true);
    final actividades = CuentaQueCambia();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          ...repositoriosFalsos(actividades: actividades),
        ],
        child: const KusdyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('María López'), findsNothing);

    await auth.cerrarSesion();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOne);

    actividades.sinActividades = false;
    await tester.enterText(
      find.widgetWithText(TextField, 'Correo'),
      AuthRepositoryFalso.correoValido,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña'),
      AuthRepositoryFalso.contrasenaValida,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('María López'), findsOne);
  });
}
