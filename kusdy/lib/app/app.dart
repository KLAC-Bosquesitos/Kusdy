import 'package:flutter/material.dart';

import 'shell.dart';
import 'theme.dart';

class KusdyApp extends StatelessWidget {
  const KusdyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kusdy',
      debugShowCheckedModeBanner: false,
      theme: kusdyTheme,
      // La app abre en la barra inferior, con la pestaña Hoy activa.
      home: const KusdyShell(),
    );
  }
}
