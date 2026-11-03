# ADR 0002 · Las pantallas hablan con un contrato, no con Supabase

- **Fecha:** 2026-10-15 (escrito en el Sprint 3)
- **Estado:** Aceptada

## Contexto

Queríamos probar las pantallas sin internet y trabajar en paralelo: una pareja en las pantallas y otra en la base de datos, sin esperarse.

## Decisión

Cada *feature* se separa en cuatro capas:

| Capa | Carpeta | Ejemplo |
|---|---|---|
| Contrato (qué se puede pedir) | `domain/` | `ClientesRepository` |
| Datos (cómo se pide) | `data/` | `ClientesRepositorySupabase`, `ClientesRepositoryFalso` |
| Estado | `presentation/*_providers.dart` | `clientesProvider` (Riverpod) |
| Pantalla | `presentation/*_screen.dart` | `ClientesScreen` |

La pantalla solo conoce el provider; el provider solo conoce el contrato. Un solo provider por *feature* decide qué implementación se usa (`clientesRepositoryProvider`).

## Consecuencias

- Las pruebas de widget cambian el repositorio con `overrideWithValue` y no necesitan red.
- Pasar de datos falsos a Supabase cambió una línea por *feature*, sin tocar pantallas.
- Hay más archivos por *feature*, y cada método nuevo se escribe dos veces (falso y Supabase).
