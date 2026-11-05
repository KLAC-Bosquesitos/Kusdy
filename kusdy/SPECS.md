# Kusdy · Specs y avance

Documento vivo para registrar en qué fase va el proyecto, qué se terminó y qué sigue. El contexto general (problema, decisiones, arquitectura y base de datos) está en [`../CLAUDE.md`](../CLAUDE.md) y las reglas para agentes de IA en [`../AGENTES.md`](../AGENTES.md).

Leyenda de estado: ✅ terminado · 🔄 en curso · ⏳ pendiente · ⛔ bloqueado o en pausa

---

## 1. Estado actual

| | |
|---|---|
| **Fase actual** | Sprint 3 cerrado: seguimiento de clientes completo (fases 2 y 3) conectado a Supabase |
| **Fase siguiente** | Hoja "Filtrar y ordenar", perfil y rol en la app (fase 1) y después productos y ventas (fase 5) |
| **Última actualización** | 2026-11-05 |
| **Bloqueos** | Ninguno. |

---

## 2. Fases

> Plan por fases **revisado el 2026-10-22** con la retroalimentación de Freddy (Propuesta). Si cambia, se actualiza aquí y en `CLAUDE.md`.

| # | Fase | Estado | Historias de usuario |
|---|---|---|---|
| 0 | Preparación | ✅ | — |
| 1 | Login y perfiles | 🔄 (login y cerrar sesión con Supabase, #27) | HU-01, HU-17 (solo rol y menús) |
| 2 | Clientes | 🔄 (Supabase, formulario y detalle con comentarios; falta "Filtrar y ordenar") | HU-02, HU-03, HU-04, HU-05, HU-13 |
| 3 | Llamadas y agenda | ✅ (Hoy, "¿Qué pasó?", Mover y Agenda desde Supabase) | HU-06, HU-07, HU-10, HU-14 |
| 4 | Recordatorios | ⏳ | HU-08 |
| 5 | Productos y ventas | 🔄 (CRUD de categorías de producto; productos y ventas pendientes) | HU-15, HU-18 |
| 6 | Cotizaciones | ⏳ | HU-09 |
| 7 | Reportes | ⏳ | HU-11, HU-16 |
| 8 | Despliegue | ⏳ | HU-12 |
| 9 | Mejoras (push, offline, onboarding, importar Excel, usuarios desde la app) | ⏳ | HU-17 |

### Fase 0 · Preparación ✅

**Objetivo:** dejar listo el repositorio, el proyecto Flutter, la base de datos y el entorno de desarrollo.

- [x] Repositorio en GitHub, CI, plantilla de PR y `CODEOWNERS`.
- [x] Proyecto Flutter creado (`kusdy/`).
- [x] Documentación base: `CLAUDE.md`, `AGENTES.md` y este `SPECS.md`.
- [x] Estructura por *features* en `lib/` (empezó con `features/clientes` y `core/widgets`).
- [x] Tema y colores en `lib/app/theme.dart` (`KusdyColors`).
- [x] Proyecto de Supabase de desarrollo (`kusdy-dev`).
- [x] Base de datos v2: 17 tablas, 2 vistas, RLS por rol y sucursal, migraciones aplicadas y copiadas a `supabase/migrations/`, pruebas en `supabase/pruebas/`.
- [ ] `supabase init` y `supabase link` en cada máquina (ver `README.md`).
- [x] Crear en el panel el usuario de Freddy, la sucursal `S01` y su perfil `jefe_sucursal`, y ponerlo como `jefe_id` de la sucursal.
- [x] Agregar los paquetes base a `pubspec.yaml`: `supabase_flutter` y `url_launcher` (`go_router` queda para después).
- [x] Inicializar Supabase en `lib/core/supabase/` con URL y llave publishable.
- [ ] Preparar el entorno de desarrollo de cada integrante.

**Criterio de terminado:** cualquier integrante puede clonar el repo, correr `flutter run` y ver la app conectada al Supabase de desarrollo.

### Fase 1 · Login y perfiles 🔄

**Objetivo:** el usuario inicia y cierra sesión con correo y contraseña, la sesión persiste, y la app conoce su rol y sucursal para mostrar solo lo que le corresponde.

- [x] Pantalla de login. #27
- [x] Inicio y cierre de sesión con Supabase Auth. #27
- [x] Sesión persistente.
- [ ] Redirección automática con `go_router` (sin sesión → login).
- [ ] Leer el perfil (`perfiles`: nombre, rol, sucursal) y exponerlo con un provider.
- [x] Navegación inferior Hoy · Clientes · Agenda · Más (#19); menú "Más" según el rol.

**Criterio de terminado:** Freddy entra con su cuenta, ve su nombre y rol, y al cerrar y abrir la app sigue con sesión.

### Fase 2 · Clientes 🔄

- [x] Lista de clientes con estados cargando, error, vacío y datos. #13
- [x] Repositorio real sobre la vista `clientes_resumen`, con borrar y Deshacer. #37
- [x] Búsqueda por nombre o teléfono y filtro por mes. #22, #37
- [ ] Hoja "Filtrar y ordenar" (no contestaron, mes de registro, producto, ciudad; orden por próxima llamada, último contacto o fecha de registro).
- [x] Formulario único de crear/editar cliente (solo nombre y teléfono obligatorios; producto de interés opcional). #36, #40
- [x] Detalle del cliente: datos, Llamar/WhatsApp, nota fija y tarjeta de Comentarios. #36
- [ ] En el detalle: Mapa, editar comentarios propios e historial de eventos.

### Fase 3 · Llamadas y agenda ✅

- [x] Migración 5 con `registrar_resultado_llamada(...)` y su prueba en el CI. #39 (la 6 agrega el producto, #40)
- [x] Widget compartido `TarjetaActividad`. #38
- [x] Pantalla Hoy con "Se te pasaron" y las de hoy (cuotas atrasadas: fase 5). #38
- [x] Pantalla dinámica "¿Qué pasó?" después de Hecho, con aviso de llamadas sin respuesta. #38
- [x] Reagendar (Mover) con atajos de fecha. #38
- [x] Agenda por día con filtro por tipo. #23, #39

### Fases 4 a 9 ⏳

Se detallan con tareas y criterio de terminado cuando la fase anterior esté por cerrarse. Lo que incluye cada una está en `CLAUDE.md`, "Plan por fases".

---


## 3. Registro de avance

Una entrada por cada cambio que se integra a `main`. La más reciente va arriba.

| Fecha | Fase | Qué se hizo | Quién | PR / Issue |
|---|---|---|---|---|
| 2026-11-05 | 1 / 3 | Cierre del Sprint 3: al cambiar de cuenta, Hoy, Agenda y Clientes cargan los datos de la nueva (antes quedaban los de la anterior hasta cerrar la app), con prueba de la app completa; estado y fases de este archivo al día; capturas al inicio del README. | @chrisram21 | #43 |
| 2026-11-04 | 2 / 3 | Arreglos tras las pruebas con usuarios: tocar el nombre en Hoy o Agenda abre el detalle del cliente; un cliente nuevo con llamada para hoy aparece enseguida en Hoy y Agenda; producto de interés al crear el cliente (opcional) y en "¿Qué pasó?" cuando le interesa (migración 6 con prueba en el CI); `docs/usuarios.md` y capturas del README. | @chrisram21 | #40 |
| 2026-11-04 | 3 | Sprint 3 · PR 2.2: pantalla dinámica «¿Qué pasó?», reagendamiento con atajos, tarjeta compartida de actividades y sección «Se te pasaron» en Hoy. Pruebas de lógica y widgets aprobadas; validación con Supabase pendiente. | @Andrea2507 y @Kennethram15 | Issue #34 · PR #38 |
| 2026-11-04 | 3 | Sprint 3 · PR 2.1: migración 5 para registrar resultados de llamadas, prueba SQL integrada al CI y repositorio de actividades conectado a Supabase para Hoy y Agenda. Migración aplicada en kusdy-dev el 2026-11-04. | @Kennethram15 y @Andrea2507 | Issue #33 · PR #39 |
| 2026-11-03 | 2 | Clientes desde Supabase: lista con filtro en el servidor, crear, editar, borrar con Deshacer y comentarios; pruebas de datos. | @WishoSz y @chrisram21 | #37 |
| 2026-11-03 | 2 | Formulario único para crear y editar clientes, detalle con Llamar/WhatsApp y tarjeta de Comentarios; pruebas de lógica y de pantalla. | @chrisram21 y @WishoSz | #36 |
| 2026-11-03 | 2 / 3 | Sprint 3 · base común: contratos de clientes, comentarios y actividades; ADR; README con el problema; plantilla de pruebas con usuarios. | @chrisram21 | #35 |
| 2026-11-01 | 5 | Lab S16 · Pareja 2: CRUD de categorías de productos con lista, formulario para crear y editar, archivado, eliminación controlada, integración desde Más, estados de consulta y ocho pruebas de widget. | @Kennethram15 y @Andrea2507 | #26 · PR #29 |
| 2026-10-22 | 0 | Contexto actualizado tras la retroalimentación de Freddy: `CLAUDE.md`, `AGENTES.md`, `README.md` y este archivo; migraciones de la BD v2 en `supabase/migrations/`, pruebas SQL, diseño de BD en `docs/bd/` y documentos de referencia en `docs/contexto/`. | Chris (con Claude) | — |
| 2026-10-22 | 0 | Base de datos v2 diseñada, probada y aplicada en `kusdy-dev` (migraciones `esquema_inicial` y `ajustes_advisors`). | Chris (con Claude) | — |
| 2026-10-17 | 4 | Lab S14 · Parte B: Inicio "Clientes para hoy" (HU-10) con estados cargando, error con Reintentar, vacío y datos; repositorio falso; navegación a Clientes y pruebas de widget. | @kennethram15 y @andrea2507 | #15 |
| 2026-10-15 | 0 / 2 | Lab S14 · Parte B: lista de clientes (HU-03) con estados cargando, error con Reintentar, vacío y datos; repositorio falso con `Future.delayed`; widgets de estado compartidos; tema `KusdyColors`; pruebas de widget. | @chrisram21 y @WishoSz | #13 |
| 2026-10-15 | 0 | Lab S14 · Parte A: CI con GitHub Actions, plantilla de PR, `CODEOWNERS`, bitácora de IA y `main` protegida. | Equipo | #12 |
| 2026-10-05 | 0 | Documentación base: `CLAUDE.md` (contexto), `AGENTES.md` (reglas para agentes) y `SPECS.md` (este archivo). | Chris | — |
| 2026-10-05 | 0 | Proyecto Flutter inicial creado. | Chris | — |
| 2026-11-01 | 5 | Lab S16 · Migración 4: categorías de producto en su propia tabla, con prueba de migración en el CI (Postgres 17) y repositorio de Supabase. | @chrisram21 y @WishoSz | #28 |

---


## 4. Decisiones tomadas

Registro breve de cada decisión. El detalle vive en `CLAUDE.md` y en `../docs/contexto/retro-fredy-2026-10.md`.

| Fecha | Decisión | Estado |
|---|---|---|
| 2026-10-22 | 5 roles (instalador, vendedor, jefe de sucursal, supervisor, gerente general); grupo de ventas = sucursal; visibilidad y administración según el rol. Reemplaza "cada vendedor ve solo lo suyo" y "sin roles". | Decisión confirmada (Freddy) |
| 2026-10-22 | Resultado de llamada como lista cerrada de 8 valores; pantalla dinámica tras "Hecho"; aviso tras 3 llamadas sin respuesta. | Decisión confirmada (Freddy) |
| 2026-10-22 | Filtros de clientes en lista (no chips); "no contestaron" = última llamada. | Decisión confirmada (Freddy) |
| 2026-10-22 | Comentarios en tabla propia, editables solo por su autor, con historial de ediciones; nota fija opcional. | Decisión confirmada (Freddy y Chris) |
| 2026-10-22 | Ventas en GTQ con número por sucursal, crédito en cuotas con seguimiento del vendedor, instalación aparte. | Decisión confirmada (Freddy) |
| 2026-10-22 | Precio de lista único con bitácora; "hasta en" por periodo; descuentos bajo el "hasta en" y precio de instalación con solicitud al jefe antes de vender. | Decisión confirmada (Freddy y Chris) |
| 2026-10-22 | Agenda solo por día, con cobros de cuotas. | Decisión confirmada (Freddy) |
| 2026-10-22 | Reportes por lo cobrado, metas mensuales por sucursal, cierre de mes por el jefe, PDF. | Decisión confirmada (Freddy) |
| 2026-10-22 | Base de datos v2 aplicada en Supabase de desarrollo; el diseño de la BD deja de estar en pausa. | Decisión confirmada (Chris) |
| 2026-10-05 | Backend y base de datos en Supabase (PostgreSQL con RLS). | Decisión confirmada |
| — | Arquitectura por *features*, Riverpod, go_router, paleta de colores y plan por fases revisado. | Propuesta |

---

## 5. Pendientes por definir

Pendientes que afectan a las próximas fases. La lista completa está en `CLAUDE.md`.

- Datos reales de productos (Chris). Afecta a la fase 5.
- Visto bueno de Freddy al diseño completo.
- Diferencia entre cita y visita. Afecta a la fase 3.
- Etapas del cliente sin validar con Freddy. Afecta a las fases 2 y 3.
- Qué llevan las cotizaciones. Afecta a la fase 6.
- Contenido exacto del reporte mensual. Afecta a la fase 7.
- Dispositivos objetivo (Android, iPhone, computadora). Afecta a la fase 8.
