import '../domain/producto_interes.dart';

class ProductosInteresRepositoryFalso implements ProductosInteresRepository {
  ProductosInteresRepositoryFalso({this.falla = false});

  final bool falla;

  @override
  Future<List<ProductoInteres>> obtenerActivos() async {
    if (falla) throw Exception('Sin conexión (simulada)');
    return productosDeEjemplo;
  }
}

const productosDeEjemplo = [
  ProductoInteres(id: 'p150', nombre: 'Calentador solar 150 L'),
  ProductoInteres(id: 'p200', nombre: 'Calentador solar 200 L'),
  ProductoInteres(id: 'p300', nombre: 'Calentador solar 300 L'),
];
