import 'package:flutter/material.dart';

import '../../app/theme.dart';

// Estado "vacío" compartido: explica qué falta y ofrece la acción para
// resolverlo, en vez de dejar la pantalla en blanco.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.mensaje,
    required this.textoAccion,
    required this.onAccion,
    this.iconoAccion = Icons.add,
  });

  final IconData icono;
  final String mensaje;
  final String textoAccion;
  final VoidCallback onAccion;

  // El botón casi siempre agrega algo (+), pero no siempre: "Quitar filtros"
  // o "Ver todos los clientes" llevan otro ícono.
  final IconData iconoAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: KusdyColors.bordeFuerte),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: KusdyColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAccion,
              icon: Icon(iconoAccion),
              label: Text(textoAccion),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 52),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
