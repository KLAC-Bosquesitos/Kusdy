// Producto que se le puede ofrecer a un cliente (calentador, panel...).
class ProductoInteres {
  const ProductoInteres({required this.id, required this.nombre});

  final String id;
  final String nombre;
}

abstract class ProductosInteresRepository {
  // Solo productos activos (no servicios), por nombre.
  Future<List<ProductoInteres>> obtenerActivos();
}
