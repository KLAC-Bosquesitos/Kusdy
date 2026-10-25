import '../domain/cliente.dart';
import '../domain/clientes_repository.dart';
import '../domain/filtro_clientes.dart';

// Cómo se comporta el repositorio falso. Se elige al correr la app:
//   flutter run --dart-define=CLIENTES_MODO=lento
enum ModoFalso {
  // Responde con clientes de ejemplo después de un momento.
  normal,
  // Tarda varios segundos: para ver el estado de carga.
  lento,
  // Falla la primera vez y responde bien después: para probar Reintentar.
  error,
  // Responde una lista vacía.
  vacio,
  // Lee bien, pero eliminar falla: para ver que la fila vuelve.
  fallaBorrar;

  static ModoFalso desdeEntorno() {
    const valor = String.fromEnvironment(
      'CLIENTES_MODO',
      defaultValue: 'normal',
    );
    return ModoFalso.values.firstWhere(
      (modo) => modo.name == valor,
      orElse: () => ModoFalso.normal,
    );
  }
}

// Clientes en memoria mientras no se conecta Supabase. Future.delayed simula
// la espera de la red. Lo eliminado se recuerda mientras la app está abierta;
// al cerrarla vuelven los datos de ejemplo (con Supabase quedará guardado).
class ClientesRepositoryFalso implements ClientesRepository {
  ClientesRepositoryFalso({
    this.modo = ModoFalso.normal,
    List<Cliente>? clientes,
    this.demora = const Duration(milliseconds: 1200),
  }) : _clientes = clientes ?? clientesDeEjemplo();

  final ModoFalso modo;
  final Duration demora;
  final List<Cliente> _clientes;
  // Ids con la marca "eliminado_en". No se quitan de la lista: así Deshacer
  // devuelve exactamente el mismo registro.
  final _eliminados = <String>{};
  var _llamadas = 0;

  @override
  Future<List<Cliente>> obtenerClientes(FiltroClientes filtro) async {
    _llamadas++;
    await Future.delayed(
      modo == ModoFalso.lento ? const Duration(seconds: 6) : demora,
    );

    if (modo == ModoFalso.error && _llamadas == 1) {
      throw Exception('Sin conexión (simulada)');
    }
    if (modo == ModoFalso.vacio) return [];
    return _clientes
        .where((c) => !_eliminados.contains(c.id) && _cumple(c, filtro))
        .toList();
  }

  @override
  Future<void> eliminarCliente(String id) async {
    await Future.delayed(demora ~/ 3);
    if (modo == ModoFalso.fallaBorrar) {
      throw Exception('Sin conexión (simulada)');
    }
    _eliminados.add(id);
  }

  @override
  Future<void> restaurarCliente(String id) async {
    await Future.delayed(demora ~/ 3);
    _eliminados.remove(id);
  }

  // Lo que en Supabase hará la consulta.
  bool _cumple(Cliente cliente, FiltroClientes filtro) {
    final mes = filtro.mes;
    if (mes != null &&
        (cliente.registradoEl.year != mes.year ||
            cliente.registradoEl.month != mes.month)) {
      return false;
    }

    final texto = filtro.texto.trim().toLowerCase();
    if (texto.isEmpty) return true;
    final telefono = cliente.telefono.replaceAll(' ', '');
    return cliente.nombre.toLowerCase().contains(texto) ||
        telefono.contains(texto.replaceAll(' ', ''));
  }
}

// Fechas relativas a hoy, para que el filtro "este mes" siempre tenga datos.
List<Cliente> clientesDeEjemplo([DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  DateTime haceMeses(int meses, int dia) =>
      DateTime(h.year, h.month - meses, dia);

  return [
    Cliente(
      id: '1',
      nombre: 'María López',
      telefono: '5512 3456',
      producto: 'Calentador solar 200 L',
      registradoEl: haceMeses(0, 1),
    ),
    Cliente(
      id: '2',
      nombre: 'José Pérez',
      telefono: '4021 7788',
      producto: 'Paneles solares',
      registradoEl: haceMeses(0, 3),
    ),
    Cliente(
      id: '3',
      nombre: 'Hotel Los Altos',
      telefono: '7761 2030',
      producto: 'Calentador solar 300 L',
      registradoEl: haceMeses(1, 14),
    ),
    Cliente(
      id: '4',
      nombre: 'Ana Gómez',
      telefono: '3390 1122',
      registradoEl: haceMeses(1, 20),
    ),
    Cliente(
      id: '5',
      nombre: 'Carlos Méndez',
      telefono: '5874 6655',
      producto: 'Calentador solar 150 L',
      registradoEl: haceMeses(2, 8),
    ),
  ];
}
