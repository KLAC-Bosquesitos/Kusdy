import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusdy/app/app.dart';
import 'package:kusdy/features/auth/data/auth_repository_falso.dart';
import 'package:kusdy/features/auth/presentation/auth_providers.dart';

// La app completa, sin sesión y con la sesión falsa (sin Supabase).
Future<void> abrirSinSesion(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(AuthRepositoryFalso()),
      ],
      child: const KusdyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> entrar(WidgetTester tester, String correo, String clave) async {
  await tester.enterText(find.widgetWithText(TextField, 'Correo'), correo);
  await tester.enterText(find.widgetWithText(TextField, 'Contraseña'), clave);
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin sesión abre el login y no la barra', (tester) async {
    await abrirSinSesion(tester);

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOne);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('con datos incorrectos muestra un mensaje para personas', (
    tester,
  ) async {
    await abrirSinSesion(tester);

    await entrar(tester, AuthRepositoryFalso.correoValido, 'otra');

    expect(find.text('Correo o contraseña incorrectos.'), findsOne);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('con campos vacíos pide llenarlos', (tester) async {
    await abrirSinSesion(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe tu correo y tu contraseña.'), findsOne);
  });

  testWidgets('con datos correctos entra a Hoy, y "Cerrar sesión" regresa', (
    tester,
  ) async {
    await abrirSinSesion(tester);

    await entrar(
      tester,
      AuthRepositoryFalso.correoValido,
      AuthRepositoryFalso.contrasenaValida,
    );
    expect(find.byType(NavigationBar), findsOne);
    expect(find.widgetWithText(AppBar, 'Clientes para hoy'), findsOne);

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOne);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
