import 'package:flutter/material.dart';

import '../features/clientes/presentation/clientes_screen.dart';
import 'theme.dart';

class KusdyApp extends StatelessWidget {
  const KusdyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kusdy',
      debugShowCheckedModeBanner: false,
      theme: kusdyTheme,
      // Por ahora la app abre directo en Clientes. La navegación con
      // go_router y las pestañas Hoy · Clientes · Agenda · Más vienen después.
      home: const ClientesScreen(),
    );
  }
}
