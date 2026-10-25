import 'cliente.dart';
import 'filtro_clientes.dart';

// Contrato que la pantalla conoce. Hoy lo cumple un repositorio falso; cuando
// se conecte Supabase lo cumplirá uno real, sin tocar la pantalla.
abstract class ClientesRepository {
  // El filtro viaja al repositorio: en Supabase se aplica en el servidor
  // (.ilike, .gte), no trayendo todos los clientes al teléfono.
  Future<List<Cliente>> obtenerClientes(FiltroClientes filtro);

  // Borrado lógico: en la base se marca clientes.eliminado_en.
  Future<void> eliminarCliente(String id);

  // Quita la marca de eliminado: vuelve el mismo registro, con el mismo id.
  Future<void> restaurarCliente(String id);
}
