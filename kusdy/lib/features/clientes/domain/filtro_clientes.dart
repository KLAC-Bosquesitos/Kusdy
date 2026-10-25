// Lo que el vendedor eligió para ver en la lista de clientes.
//
// Es inmutable: no se cambia un campo, se crea un filtro nuevo. Así Riverpod
// puede comparar el filtro viejo con el nuevo (==) y, si es distinto, repetir
// la consulta sola.
class FiltroClientes {
  const FiltroClientes({this.texto = '', this.mes});

  // Búsqueda por nombre o teléfono. Vacío = sin búsqueda.
  final String texto;

  // Mes de registro (día 1 del mes). null = todos los meses.
  final DateTime? mes;

  bool get activo => texto.trim().isNotEmpty || mes != null;

  @override
  bool operator ==(Object other) =>
      other is FiltroClientes && other.texto == texto && other.mes == mes;

  @override
  int get hashCode => Object.hash(texto, mes);
}
