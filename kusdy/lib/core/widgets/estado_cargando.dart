import 'package:flutter/material.dart';

import '../../app/theme.dart';

// Estado "cargando" que comparten todas las pantallas que leen datos.
// Lleva texto además del círculo para que no parezca que la app se congeló.
class EstadoCargando extends StatelessWidget {
  const EstadoCargando({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: const TextStyle(
              fontSize: 16,
              color: KusdyColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
