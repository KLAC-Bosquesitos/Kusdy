# Kusdy · Specs y avance

Documento vivo para registrar en qué fase va el proyecto, qué se terminó y qué sigue. El contexto general (problema, decisiones, arquitectura y base de datos) está en [`../CLAUDE.md`](../CLAUDE.md) y las reglas para agentes de IA en [`../AGENTES.md`](../AGENTES.md).

Leyenda de estado: ✅ terminado · 🔄 en curso · ⏳ pendiente · ⛔ bloqueado o en pausa

---

## 1. Estado actual

| | |
|---|---|
| **Fase actual** | 0. Preparación 🔄 (falta conectar la app a Supabase) |
| **Fase siguiente** | 1. Login y perfiles; en paralelo se pueden construir pantallas de la fase 2 y 3 con repositorios falsos |
| **Última actualización** | 2026-10-24 |
| **Bloqueos** | Ninguno para programar. La tabla `productos` es provisional hasta tener los datos reales (afecta a la fase 5). |

---

## 2. Fases

> Plan por fases **revisado el 2026-10-22** con la retroalimentación de Freddy (Propuesta). Si cambia, se actualiza aquí y en `CLAUDE.md`.

| # | Fase | Estado | Historias de usuario |
|---|---|---|---|
| 0 | Preparación | 🔄 | — |
| 1 | Login y perfiles | ⏳ | HU-01, HU-17 (solo rol y menús) |
| 2 | Clientes | 🔄 (lista con datos falsos) | HU-02, HU-03, HU-04, HU-05, HU-13 |
| 3 | Llamadas y agenda | 🔄 (Agenda inicial con repositorio falso) | HU-06, HU-07, HU-10, HU-14 |
| 4 | Recordatorios | ⏳ | HU-08 |
| 5 | Productos y ventas | ⏳ | HU-15, HU-18 |
| 6 | Cotizaciones | ⏳ | HU-09 |
| 7 | Reportes | ⏳ | HU-11, HU-16 |
| 8 | Despliegue | ⏳ | HU-12 |
| 9 | Mejoras (push, offline, onboarding, importar Excel, usuarios desde la app) | ⏳ | HU-17 |

### Fase 0 · Preparación 🔄

**Objetivo:** dejar listo el repositorio, el proyecto Flutter, la base de datos y el entorno de desarrollo.

- [x] Repositorio en GitHub, CI, plantilla de PR y `CODEOWNERS`.
- [x] Proyecto Flutter creado (`kusdy/`).
- [x] Documentación base: `CLAUDE.md`, `AGENTES.md` y este `SPECS.md`.
- [x] Estructura por *features* en `lib/` (empezó con `features/clientes` y `core/widgets`).
- [x] Tema y colores en `lib/app/theme.dart` (`KusdyColors`).
- [x] Proyecto de Supabase de desarrollo (`kusdy-dev`).
- [x] Base de datos v2: 17 tablas, 2 vistas, RLS por rol y sucursal, migraciones aplicadas y copiadas a `supabase/migrations/`, pruebas en `supabase/pruebas/`.
- [ ] `supabase init` y `supabase link` en cada máquina (ver `README.md`).
- [ ] Crear en el panel el usuario de Freddy, la sucursal `S01` y su perfil `jefe_sucursal`, y ponerlo como `jefe_id` de la sucursal.
- [ ] Agregar los paquetes base a `pubspec.yaml`: `supabase_flutter`, `go_router`, `intl` (y `freezed`/`json_serializable` si el equipo lo confirma).
- [ ] Inicializar Supabase en `lib/core/supabase/` con URL y llave publishable (propuesta: `--dart-define`).
- [ ] Preparar el entorno de desarrollo de cada integrante.

**Criterio de terminado:** cualquier integrante puede clonar el repo, correr `flutter run` y ver la app conectada al Supabase de desarrollo.

### Fase 1 · Login y perfiles ⏳

**Objetivo:** el usuario inicia y cierra sesión con correo y contraseña, la sesión persiste, y la app conoce su rol y sucursal para mostrar solo lo que le corresponde.

- [ ] Pantalla de login.
- [ ] Inicio y cierre de sesión con Supabase Auth.
- [ ] Sesión persistente.
- [ ] Redirección automática con `go_router` (sin sesión → login).
- [ ] Leer el perfil (`perfiles`: nombre, rol, sucursal) y exponerlo con un provider.
- [ ] Navegación inferior Hoy · Clientes · Agenda · Más; menú "Más" según el rol.

**Criterio de terminado:** Freddy entra con su cuenta, ve su nombre y rol, y al cerrar y abrir la app sigue con sesión.

### Fase 2 · Clientes 🔄

- [x] Lista de clientes con estados cargando, error, vacío y datos (repositorio falso). #13
- [ ] Repositorio real sobre la vista `clientes_resumen`.
- [ ] Búsqueda por nombre o teléfono.
- [ ] Hoja "Filtrar y ordenar" (no contestaron, mes de registro, producto, ciudad; orden por próxima llamada, último contacto o fecha de registro).
- [ ] Formulario único de crear/editar cliente (solo nombre y teléfono obligatorios).
- [ ] Detalle del cliente: datos, Llamar/WhatsApp/Mapa, nota fija, tarjeta de Comentarios (crear y editar los propios, "(editado)") e historial de eventos.

### Fase 3 · Llamadas y agenda 🔄

- [ ] Migración aditiva con `registrar_resultado_llamada(...)` y `agenda(dia, vendedor)`.
- [ ] Widget compartido `TarjetaActividad`.
- [ ] Pantalla Hoy completa (se te pasaron, hoy, cuotas atrasadas).
- [ ] Pantalla dinámica "¿Qué pasó?" después de Hecho, con aviso de llamadas sin respuesta.
- [ ] Reagendar (Mover) con atajos de fecha.
- [x] Lab S15 · Issue #21: pantalla inicial de Agenda por día, integrada en la navegación inferior. Incluye filtros reactivos por fecha y tipo de actividad mediante Riverpod, estados de carga, error, vacío y datos, cancelación mediante deslizamiento con opción Deshacer y pruebas de widget. Implementación con repositorio falso en memoria.
- [ ] Completar Agenda con el registro de nuevas actividades mediante el botón +, cobros de cuotas y conexión al repositorio real de Supabase.

### Fases 4 a 9 ⏳

Se detallan con tareas y criterio de terminado cuando la fase anterior esté por cerrarse. Lo que incluye cada una está en `CLAUDE.md`, "Plan por fases".

---

## 3. Registro de avance

Una entrada por cada cambio que se integra a `main`. La más reciente va arriba.

| Fecha | Fase | Qué se hizo | Quién | PR / Issue |
|---|---|---|---|---|
| 2026-10-24 | 3 | Lab S15 · Pareja 2: implementación de la pantalla Agenda por día, con filtros reactivos por fecha y tipo de actividad mediante Riverpod. Se incorporaron los cuatro estados de consulta (cargando, error, vacío y datos), cancelación de actividades mediante deslizamiento y opción Deshacer. Se utilizó un repositorio falso en memoria y se integraron pruebas de widget. La ejecución general de `flutter test` finalizó con 19 pruebas aprobadas. | @kennethram15 y @andrea2507 | #21 / PR pendiente |
| 2026-10-22 | 0 | Contexto actualizado tras la retroalimentación de Freddy: `CLAUDE.md`, `AGENTES.md`, `README.md` y este archivo; migraciones de la BD v2 en `supabase/migrations/`, pruebas SQL, diseño de BD en `docs/bd/` y documentos de referencia en `docs/contexto/`. | Chris (con Claude) | — |
| 2026-10-22 | 0 | Base de datos v2 diseñada, probada y aplicada en `kusdy-dev` (migraciones `esquema_inicial` y `ajustes_advisors`). | Chris (con Claude) | — |
| 2026-10-17 | 4 | Lab S14 · Parte B: Inicio "Clientes para hoy" (HU-10) con estados cargando, error con Reintentar, vacío y datos; repositorio falso; navegación a Clientes y pruebas de widget. | @kennethram15 y @andrea2507 | #15 |
| 2026-10-15 | 0 / 2 | Lab S14 · Parte B: lista de clientes (HU-03) con estados cargando, error con Reintentar, vacío y datos; repositorio falso con `Future.delayed`; widgets de estado compartidos; tema `KusdyColors`; pruebas de widget. | @chrisram21 y @WishoSz | #13 |
| 2026-10-15 | 0 | Lab S14 · Parte A: CI con GitHub Actions, plantilla de PR, `CODEOWNERS`, bitácora de IA y `main` protegida. | Equipo | #12 |
| 2026-10-05 | 0 | Documentación base: `CLAUDE.md` (contexto), `AGENTES.md` (reglas para agentes) y `SPECS.md` (este archivo). | Chris | — |
| 2026-10-05 | 0 | Proyecto Flutter inicial creado. | Chris | — |

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
