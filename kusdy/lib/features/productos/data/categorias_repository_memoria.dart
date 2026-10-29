import '../domain/categoria_producto.dart';
import '../domain/categorias_repository.dart';

// Categorías en memoria, con las MISMAS reglas que la base: nombre único sin
// importar mayúsculas y no borrar lo que está en uso. Lo usan las pruebas de
// widget (sin internet) y la app mientras no entra el PR de Supabase.
// Al cerrar la app se pierde lo que se haya creado.
class CategoriasRepositoryMemoria implements CategoriasRepository {
  CategoriasRepositoryMemoria({
    List<CategoriaProducto>? categorias,
    this.demora = const Duration(milliseconds: 400),
  }) : _categorias = [...categorias ?? categoriasDeEjemplo()];

  final Duration demora;
  final List<CategoriaProducto> _categorias;
  var _ultimoId = 100;

  @override
  Future<List<CategoriaProducto>> obtenerTodas() async {
    await Future<void>.delayed(demora);
    return [..._categorias]..sort((a, b) {
      if (a.archivada != b.archivada) return a.archivada ? 1 : -1;
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
  }

  @override
  Future<void> guardar({String? id, required String nombre}) async {
    await Future<void>.delayed(demora);
    final limpio = nombreCategoriaValido(nombre);
    final repetida = _categorias.any(
      (c) => c.id != id && c.nombre.toLowerCase() == limpio.toLowerCase(),
    );
    if (repetida) throw CategoriaException.repetida(limpio);

    if (id == null) {
      _ultimoId++;
      _categorias.add(CategoriaProducto(id: 'c$_ultimoId', nombre: limpio));
      return;
    }
    final i = _indice(id);
    final actual = _categorias[i];
    _categorias[i] = CategoriaProducto(
      id: actual.id,
      nombre: limpio,
      archivada: actual.archivada,
      productos: actual.productos,
    );
  }

  @override
  Future<void> archivar(String id, {required bool archivada}) async {
    await Future<void>.delayed(demora);
    final i = _indice(id);
    final actual = _categorias[i];
    _categorias[i] = CategoriaProducto(
      id: actual.id,
      nombre: actual.nombre,
      archivada: archivada,
      productos: actual.productos,
    );
  }

  @override
  Future<void> eliminar(String id) async {
    await Future<void>.delayed(demora);
    final categoria = _categorias[_indice(id)];
    if (categoria.enUso) throw CategoriaException.enUso(categoria.productos);
    _categorias.removeWhere((c) => c.id == id);
  }

  int _indice(String id) {
    final i = _categorias.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('No existe la categoría $id');
    return i;
  }
}

// Las mismas tres categorías que deja la migración 4 con la lista de precios
// real (mayo 2026).
List<CategoriaProducto> categoriasDeEjemplo() => const [
  CategoriaProducto(
    id: 'c1',
    nombre: 'Calentador solar por gravedad',
    productos: 5,
  ),
  CategoriaProducto(
    id: 'c2',
    nombre: 'Calentador solar presurizado',
    productos: 5,
  ),
  CategoriaProducto(id: 'c3', nombre: 'Servicios', productos: 1),
];
