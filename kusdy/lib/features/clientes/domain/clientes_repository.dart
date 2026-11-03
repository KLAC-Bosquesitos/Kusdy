import 'cliente.dart';
import 'datos_cliente.dart';
import 'filtro_clientes.dart';

// Contrato que conocen las pantallas de clientes. Los errores llegan como
// ClienteException, con un mensaje para personas.
abstract class ClientesRepository {
  Future<List<Cliente>> obtenerClientes(FiltroClientes filtro);

  Future<Cliente> obtenerCliente(String id);

  // Devuelve el id del cliente nuevo.
  Future<String> crearCliente(DatosCliente datos);

  Future<void> actualizarCliente(String id, DatosCliente datos);

  // Borrado lógico: clientes.eliminado_en.
  Future<void> eliminarCliente(String id);

  Future<void> restaurarCliente(String id);
}
