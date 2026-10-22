import 'package:flutter/material.dart';

import '../features/hoy/presentation/hoy_screen.dart';
import 'theme.dart';

class KusdyApp extends StatelessWidget {
  const KusdyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kusdy',
      debugShowCheckedModeBanner: false,
      theme: kusdyTheme,
      // La app abre en Inicio ("Clientes para hoy"); desde ahí se llega a
      // Clientes. Las pestañas Hoy · Clientes · Agenda · Más vienen después.
      home: const HoyScreen(),
    );
  }
}
