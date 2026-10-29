import 'categoria_producto.dart';

// Contrato que conocen las pantallas. Hoy lo cumple un repositorio en memoria;
// la pareja de la migración agrega el de Supabase, sin tocar las pantallas.
abstract class CategoriasRepository {
  // Activas primero y luego archivadas, cada grupo por nombre.
  Future<List<CategoriaProducto>> obtenerTodas();

  // id == null crea una categoría; con id es un UPDATE de esa misma fila
  // (el id no cambia). Lanza CategoriaException si el nombre está vacío o
  // ya existe.
  Future<void> guardar({String? id, required String nombre});

  Future<void> archivar(String id, {required bool archivada});

  // Solo se borra si ningún producto la usa; si no, lanza CategoriaException
  // y la categoría queda igual.
  Future<void> eliminar(String id);
}
