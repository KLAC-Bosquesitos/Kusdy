# Instrucciones para agentes de IA

Este archivo dice cómo debe trabajar cualquier agente de IA (Claude, Copilot, Cursor u otro) dentro del repositorio de Kusdy. Si algo de aquí choca con una instrucción directa de un integrante del equipo, gana la instrucción del integrante.

## 1. Antes de empezar

Lee siempre, en este orden:

1. [`CLAUDE.md`](CLAUDE.md): qué es Kusdy, alcance, decisiones confirmadas, arquitectura, resumen de la base de datos y pendientes.
2. [`kusdy/SPECS.md`](kusdy/SPECS.md): fase actual, tareas abiertas y registro de avance.
3. Este archivo.

Según la tarea, lee además:

- **Pantallas:** la sección del punto que corresponda en [`docs/contexto/retro-fredy-2026-10.md`](docs/contexto/retro-fredy-2026-10.md) (filtros = punto 1, comentarios = 2, "Hecho" dinámico = 3, ventas y precios = 4, roles y reportes = 5, Agenda = 6) y [`docs/contexto/revision-bocetos.md`](docs/contexto/revision-bocetos.md).
- **Datos o repositorios:** [`docs/bd/diseno-bd-v2.md`](docs/bd/diseno-bd-v2.md) y la migración en [`supabase/migrations/`](supabase/migrations/). Los nombres de columnas y valores de los enums salen del SQL; no los adivines.
- **Historias de usuario o reglas de negocio:** [`docs/contexto/KUSDY_CONTEXT.md`](docs/contexto/KUSDY_CONTEXT.md) (HU-01 a HU-18).

Los documentos de `docs/contexto/` son copias del espacio de trabajo del proyecto (2026-10-22) y mencionan rutas como `kusdy/bd/...` o `kusdy/plan-tecnico-v1.md` que no existen en este repo; usa la tabla de `docs/contexto/README.md` para ubicarlas.

Si la tarea que te piden no corresponde a la fase actual de `SPECS.md`, avísalo antes de empezar.

## 2. Para qué sirve cada archivo

Cada cosa va en su lugar. No dupliques información entre archivos.

| Archivo | Qué contiene | Cuándo se edita |
|---|---|---|
| `CLAUDE.md` | Contexto del producto y decisiones técnicas. | Solo cuando el equipo confirma una decisión nueva o cambia el alcance. |
| `AGENTES.md` | Reglas de trabajo para agentes. | Solo si el equipo lo pide. |
| `kusdy/SPECS.md` | Fases, tareas, registro de avance y decisiones tomadas. | Al terminar una tarea o fase. |
| `kusdy/lib/` | Código de la app. | En cada tarea de desarrollo. |
| `supabase/migrations/` | Migraciones SQL, en orden. | Solo agregando un archivo nuevo, y solo si la tarea lo pide. |
| `docs/bd/diseno-bd-v2.md` | Explicación de la base de datos. | Cuando una migración nueva cambie lo que describe. |
| `docs/contexto/` | Copias de referencia (retro de Freddy, contexto de negocio, bocetos, paleta). | No se editan; si algo cambió, se anota en `CLAUDE.md`. |

## 3. Una tarea a la vez

- Trabaja solo en lo que te pidieron. No aproveches para "arreglar" otras partes, renombrar archivos ajenos ni reorganizar carpetas.
- Si ves algo que conviene cambiar fuera de la tarea, anótalo como sugerencia en tu respuesta, no lo cambies.
- Un cambio = una rama = un Pull Request. No mezcles en el mismo PR una funcionalidad, un refactor y cambios de documentación que no tengan relación.
- No toques `main` directamente. El flujo es: Issue -> Rama -> Pull Request -> Revisión -> Merge.
- No hagas commit ni push a menos que el integrante te lo pida. Por defecto deja los cambios listos para que la persona los revise.

## 4. Nombres de ramas y commits

**Propuesta** de convención:

- Ramas: `tipo/descripcion-corta`, por ejemplo `feat/login`, `fix/busqueda-clientes`, `docs/specs-fase-1`, `chore/paquetes-base`.
- Commits: `tipo: descripción en español`, por ejemplo `feat: pantalla de login`.
- Tipos: `feat` (funcionalidad), `fix` (error), `docs` (documentación), `refactor`, `test`, `chore` (configuración o dependencias).

## 5. Código

- Respeta la arquitectura por *features* de `CLAUDE.md`: `lib/features/<feature>/{data,domain,presentation}`. Lo compartido va en `lib/core/` y lo de arranque en `lib/app/`.
- Las pantallas nunca llaman a Supabase directamente. Siempre pasan por un repositorio de la capa `data`. Cada repositorio tiene su interfaz en `domain/` y, además de la versión con Supabase, una versión falsa para las pruebas de widget (como `clientes_repository_falso.dart`).
- Los estados de carga, error y vacío usan `AsyncValue` y los widgets de `lib/core/widgets/` (`EstadoCargando`, `EstadoError`, `EstadoVacio`). No inventes otros.
- Las listas cerradas de la base de datos (rol, tipo y estado de actividad, resultado de llamada, etapa...) van como `enum` de Dart con los mismos valores que el enum de Postgres, y su texto para la pantalla en español natural ("No contestó", no `no_contesto`).
- Para la lista de clientes consulta la vista `clientes_resumen`, no `clientes` más cálculos en la app.
- Lo que toca varias tablas (resultado de llamada, venta, abono, responder solicitud) se hace con una sola llamada `rpc()` a su función SQL. Si la función todavía no existe, dilo; no lo armes con varias escrituras desde la app.
- Fechas: la base guarda `timestamptz`; la app las muestra en hora de Guatemala y en español. Dinero: quetzales, formato `Q 4,900.00`.
- Los nombres del dominio van en español (`Cliente`, `Actividad`, `Cotizacion`, `clientes_repository.dart`). Los términos técnicos de Flutter se dejan como son (`Widget`, `Provider`, `build`).
- Los colores salen solo de `KusdyColors` en `lib/app/theme.dart`. Nunca escribas un `Color(0xFF...)` suelto.
- No agregues paquetes nuevos a `pubspec.yaml` sin decir cuál y por qué. Usa los de la tabla de paquetes de `CLAUDE.md`.
- Antes de dar una tarea por terminada, corre dentro de `kusdy/`:
  - `flutter analyze` (sin errores nuevos).
  - `flutter test` (si hay pruebas).

## 6. Supabase y seguridad

- **La base de datos v2 ya está aplicada** en el proyecto de desarrollo `kusdy-dev` (2026-10-22). Las migraciones de `supabase/migrations/` reflejan exactamente lo que hay en el servidor.
- **Nunca edites una migración que ya existe.** Cualquier cambio es un archivo nuevo `supabase/migrations/<AAAAMMDDHHMMSS>_<descripcion>.sql`, preferiblemente aditivo (agregar funciones, columnas opcionales o tablas). Antes de crearlo, pregunta a Chris; no la apliques en Supabase sin que él lo pida.
- Toda tabla nueva lleva Row Level Security activa desde su creación y sus políticas usan `puede_ver(...)` como las demás.
- Nunca pongas la clave `service_role` / secret ni contraseñas en el código, en commits ni en archivos de documentación. La app solo usa la clave **publishable** (está en `CLAUDE.md`, sección "Supabase").
- Los cambios de base de datos se hacen solo con migraciones SQL guardadas en el repositorio, nunca a mano desde el panel.
- No escribas directo en `ventas`, `venta_lineas`, `cuotas`, `pagos` ni `cierres_mensuales`: la RLS lo rechaza a propósito. Van por funciones SQL.
- `productos` es provisional hasta que lleguen los datos reales; no construyas pantallas que dependan de columnas que aún no existen.

## 7. Decisiones y requerimientos

- No inventes requerimientos. Si algo no está en `CLAUDE.md` o en `SPECS.md`, es un pendiente: pregúntalo.
- Cuando propongas algo nuevo, márcalo como **Propuesta**. Solo el equipo lo convierte en **Decisión confirmada**.
- No amplíes el alcance hacia lo que `CLAUDE.md` marca como fuera de alcance (SaaS, permisos configurables más allá de los 5 roles fijos, ERP, inventario, facturación, e-commerce).

## 8. Al terminar una tarea

1. Actualiza `kusdy/SPECS.md`: marca la tarea como hecha y, si la fase cambió, actualiza el "Estado actual".
2. Agrega una entrada al "Registro de avance" con fecha, fase, qué se hizo y quién lo pidió.
3. Si se confirmó una decisión nueva, anótala en "Decisiones tomadas" de `SPECS.md` y actualiza `CLAUDE.md`.
4. Resume en tu respuesta qué archivos cambiaste y qué falta revisar.
