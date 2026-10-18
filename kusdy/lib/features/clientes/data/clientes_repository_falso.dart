import '../domain/cliente.dart';
import '../domain/clientes_repository.dart';

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
  vacio;

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

// Datos fijos mientras el diseño de la base de datos está en pausa.
// Future.delayed simula la espera de la red.
class ClientesRepositoryFalso implements ClientesRepository {
  ClientesRepositoryFalso({this.modo = ModoFalso.normal});

  final ModoFalso modo;
  var _llamadas = 0;

  @override
  Future<List<Cliente>> obtenerClientes() async {
    _llamadas++;
    await Future.delayed(
      modo == ModoFalso.lento
          ? const Duration(seconds: 6)
          : const Duration(milliseconds: 1200),
    );

    if (modo == ModoFalso.error && _llamadas == 1) {
      throw Exception('Sin conexión (simulada)');
    }
    if (modo == ModoFalso.vacio) return [];
    return clientesDeEjemplo;
  }
}

const clientesDeEjemplo = [
  Cliente(
    id: '1',
    nombre: 'María López',
    telefono: '5512 3456',
    producto: 'Calentador solar 200 L',
  ),
  Cliente(
    id: '2',
    nombre: 'José Pérez',
    telefono: '4021 7788',
    producto: 'Paneles solares',
  ),
  Cliente(
    id: '3',
    nombre: 'Hotel Los Altos',
    telefono: '7761 2030',
    producto: 'Calentador solar 300 L',
  ),
  Cliente(id: '4', nombre: 'Ana Gómez', telefono: '3390 1122'),
  Cliente(
    id: '5',
    nombre: 'Carlos Méndez',
    telefono: '5874 6655',
    producto: 'Calentador solar 150 L',
  ),
];
