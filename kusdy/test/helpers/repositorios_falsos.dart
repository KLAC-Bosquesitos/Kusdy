import 'package:flutter_riverpod/misc.dart';
import 'package:kusdy/features/agenda/data/actividades_repository_falso.dart';
import 'package:kusdy/features/agenda/domain/actividades_repository.dart';
import 'package:kusdy/features/agenda/presentation/agenda_providers.dart';
import 'package:kusdy/features/clientes/data/clientes_repository_falso.dart';
import 'package:kusdy/features/clientes/data/comentarios_repository_falso.dart';
import 'package:kusdy/features/clientes/presentation/clientes_providers.dart';
import 'package:kusdy/features/productos/data/productos_interes_repository_falso.dart';
import 'package:kusdy/features/productos/presentation/productos_interes_providers.dart';

// Para pruebas de la app completa: ningún repositorio toca Supabase.
List<Override> repositoriosFalsos({ActividadesRepository? actividades}) => [
  clientesRepositoryProvider.overrideWithValue(ClientesRepositoryFalso()),
  comentariosRepositoryProvider.overrideWithValue(ComentariosRepositoryFalso()),
  actividadesRepositoryProvider.overrideWithValue(
    actividades ?? ActividadesRepositoryFalso(),
  ),
  productosInteresRepositoryProvider.overrideWithValue(
    ProductosInteresRepositoryFalso(),
  ),
];
