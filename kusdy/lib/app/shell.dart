import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/mas/presentation/mas_screen.dart';
import '../features/agenda/presentation/agenda_screen.dart';
import '../features/clientes/presentation/clientes_screen.dart';
import '../features/hoy/presentation/hoy_screen.dart';
import 'pestana.dart';

// Estructura principal: barra inferior Hoy · Clientes · Agenda · Más.
// IndexedStack mantiene vivas las cuatro pantallas, por eso al volver a una
// pestaña se conserva su scroll y no se vuelven a pedir los datos.
class KusdyShell extends ConsumerWidget {
  const KusdyShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pestana = ref.watch(pestanaProvider);

    return Scaffold(
      body: IndexedStack(
        index: pestana.index,
        // El orden debe coincidir con el de Pestana.
        children: const [
          HoyScreen(),
          ClientesScreen(),
          AgendaScreen(),
          MasScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pestana.index,
        onDestinationSelected: (i) =>
            ref.read(pestanaProvider.notifier).ir(Pestana.values[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Más'),
        ],
      ),
    );
  }
}
