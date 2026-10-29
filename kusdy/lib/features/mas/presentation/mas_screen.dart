import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/proximamente.dart';
import '../../auth/presentation/auth_providers.dart';

// Pestaña "Más": lo que no cabe en la barra (catálogo, reportes, usuarios) y
// cerrar sesión. Cada opción abre su pantalla encima, con flecha para volver;
// lo que todavía no existe abre "Próximamente".
class MasScreen extends ConsumerWidget {
  const MasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Más'),
        backgroundColor: KusdyColors.superficie,
        foregroundColor: KusdyColors.primarioOscuro,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _Opcion(
            icono: Icons.category_outlined,
            titulo: 'Categorías de productos',
            // Lab S16: la pareja de las pantallas cambia esto por
            // CategoriasScreen().
            destino: PantallaProximamente(
              titulo: 'Categorías de productos',
              icono: Icons.category_outlined,
            ),
          ),
          const _Opcion(
            icono: Icons.inventory_2_outlined,
            titulo: 'Productos',
            destino: PantallaProximamente(
              titulo: 'Productos',
              icono: Icons.inventory_2_outlined,
            ),
          ),
          const _Opcion(
            icono: Icons.bar_chart,
            titulo: 'Reportes',
            destino: PantallaProximamente(
              titulo: 'Reportes',
              icono: Icons.bar_chart,
            ),
          ),
          const _Opcion(
            icono: Icons.manage_accounts_outlined,
            titulo: 'Usuarios',
            destino: PantallaProximamente(
              titulo: 'Usuarios',
              icono: Icons.manage_accounts_outlined,
            ),
          ),
          const Divider(height: 24),
          ListTile(
            minTileHeight: 64,
            leading: const Icon(Icons.logout, color: KusdyColors.vencido),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(fontSize: 18, color: KusdyColors.vencido),
            ),
            // La puerta de la app escucha la sesión y vuelve sola al login.
            onTap: () => ref.read(authRepositoryProvider).cerrarSesion(),
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.destino,
  });

  final IconData icono;
  final String titulo;
  final Widget destino;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 64,
      leading: Icon(icono, color: KusdyColors.primario),
      title: Text(titulo, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => destino)),
    );
  }
}
