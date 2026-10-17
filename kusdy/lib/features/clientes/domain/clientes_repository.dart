import 'cliente.dart';

// Contrato que la pantalla conoce. Hoy lo cumple un repositorio falso; cuando
// exista la base de datos lo cumplirá uno de Supabase, sin tocar la pantalla.
abstract class ClientesRepository {
  Future<List<Cliente>> obtenerClientes();
}
