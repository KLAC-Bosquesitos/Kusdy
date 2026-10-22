# Kusdy

CRM móvil a medida para Energica Solar S.A., hecho en Flutter con Supabase como backend. Centraliza clientes, llamadas, citas, visitas, ventas y seguimientos para que a los vendedores no se les pase nada.

## Documentación

| Archivo | Para qué sirve |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Contexto completo: problema, usuario, decisiones, arquitectura, base de datos y pendientes. |
| [`kusdy/SPECS.md`](kusdy/SPECS.md) | Fase actual, tareas y registro de avance. |
| [`AGENTES.md`](AGENTES.md) | Reglas para los agentes de IA que trabajen en el proyecto. |
| [`docs/bd/diseno-bd-v2.md`](docs/bd/diseno-bd-v2.md) | Diseño de la base de datos y permisos. |
| [`docs/contexto/`](docs/contexto/) | Retroalimentación de Freddy, contexto de negocio, bocetos y paleta. |

## Estructura

- `kusdy/`: proyecto Flutter de la aplicación.
- `supabase/migrations/`: migraciones SQL de la base de datos (ya aplicadas en desarrollo).
- `supabase/pruebas/`: pruebas SQL de permisos y reglas.
- `docs/`: documentación de apoyo y bitácora de IA.

## Cómo correr la app

```bash
cd kusdy
flutter pub get
flutter run
```

## Base de datos (Supabase de desarrollo)

Requiere la [Supabase CLI](https://supabase.com/docs/guides/cli). Una sola vez por máquina, desde la raíz del repo:

```bash
supabase init            # crea supabase/config.toml; no toca las migraciones
supabase link --project-ref dygbykkhdnpuoapbkaip
supabase migration list  # las dos migraciones deben salir sincronizadas
```

Nunca se edita una migración existente: cada cambio es un archivo nuevo en `supabase/migrations/`.

## Flujo de trabajo

Issue -> Rama -> Pull Request -> Revisión -> Merge. Nadie trabaja directamente sobre `main`.
