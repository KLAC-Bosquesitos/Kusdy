import 'package:flutter/material.dart';

import '../../app/theme.dart';

// Pantalla para lo que todavía no existe. Así ningún botón de la barra queda
// sin hacer nada.
class PantallaProximamente extends StatelessWidget {
  const PantallaProximamente({
    super.key,
    required this.titulo,
    required this.icono,
  });

  final String titulo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 56, color: KusdyColors.bordeFuerte),
              const SizedBox(height: 16),
              const Text(
                'Próximamente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: KusdyColors.texto,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estamos trabajando en esta sección.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: KusdyColors.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
