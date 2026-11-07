import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'puerta_sesion.dart';
import 'theme.dart';

class KusdyApp extends StatelessWidget {
  const KusdyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kusdy',
      debugShowCheckedModeBanner: false,
      theme: kusdyTheme,
      // Calendario, reloj y textos de Material en español.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Sin sesión abre el login; con sesión, la barra con la pestaña Hoy.
      home: const PuertaSesion(),
    );
  }
}
