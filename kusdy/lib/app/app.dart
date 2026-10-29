import 'package:flutter/material.dart';

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
      // Sin sesión abre el login; con sesión, la barra con la pestaña Hoy.
      home: const PuertaSesion(),
    );
  }
}
