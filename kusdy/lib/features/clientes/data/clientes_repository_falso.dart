import '../domain/cliente.dart';
import '../domain/clientes_repository.dart';
import '../domain/datos_cliente.dart';
import '../domain/filtro_clientes.dart';
import '../../productos/data/productos_interes_repository_falso.dart';

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
  }) : _clientes = [...(clientes ?? clientesDeEjemplo())];

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
  Future<Cliente> obtenerCliente(String id) async {
    await Future.delayed(demora ~/ 3);
    return _clientes.firstWhere(
      (c) => c.id == id && !_eliminados.contains(id),
      orElse: () => throw const ClienteException('Ese cliente ya no existe.'),
    );
  }

  @override
  Future<String> crearCliente(DatosCliente datos) async {
    await Future.delayed(demora ~/ 3);
    final id = 'nuevo-${_clientes.length + 1}';
    _clientes.insert(0, _desdeDatos(id, datos, DateTime.now()));
    return id;
  }

  @override
  Future<void> actualizarCliente(String id, DatosCliente datos) async {
    await Future.delayed(demora ~/ 3);
    final i = _clientes.indexWhere((c) => c.id == id);
    if (i == -1) throw const ClienteException('Ese cliente ya no existe.');
    final antes = _clientes[i];
    _clientes[i] = _desdeDatos(id, datos, antes.registradoEl, antes);
  }

  Cliente _desdeDatos(
    String id,
    DatosCliente d,
    DateTime registradoEl, [
    Cliente? antes,
  ]) {
    return Cliente(
      id: id,
      nombre: d.nombre,
      telefono: d.telefono,
      direccion: d.direccion,
      ciudad: d.ciudad,
      notaFija: d.notaFija,
      registradoEl: registradoEl,
      productoId: d.productoInteresId,
      producto: productosDeEjemplo
          .where((p) => p.id == d.productoInteresId)
          .firstOrNull
          ?.nombre,
      ultimoContacto: antes?.ultimoContacto,
      proximaLlamada: antes?.proximaLlamada ?? d.primeraLlamada,
      noContesto: antes?.noContesto ?? false,
      intentosSinRespuesta: antes?.intentosSinRespuesta ?? 0,
    );
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
      ciudad: 'Quetzaltenango',
      notaFija: 'Prefiere que la llamen después de las 5 p. m.',
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
      ciudad: 'Quetzaltenango',
      registradoEl: haceMeses(1, 14),
      noContesto: true,
      intentosSinRespuesta: 3,
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
