import 'package:flutter_riverpod/flutter_riverpod.dart';

// Las pestañas de la barra inferior, en el orden en que se ven.
enum Pestana { hoy, clientes, agenda, mas }

// La pestaña activa vive aquí y no en un setState del shell: así cualquier
// pantalla puede cambiarla (por ejemplo "Ver todos los clientes" en Hoy) sin
// recibir funciones por el constructor.
class PestanaNotifier extends Notifier<Pestana> {
  @override
  Pestana build() => Pestana.hoy;

  void ir(Pestana pestana) => state = pestana;
}

final pestanaProvider = NotifierProvider<PestanaNotifier, Pestana>(
  PestanaNotifier.new,
);
