# Kusdy · Specs y avance

Documento vivo para registrar en qué fase va el proyecto, qué se terminó y qué sigue. El contexto general (problema, alcance y decisiones técnicas) está en [`../CLAUDE.md`](../CLAUDE.md) y las reglas para agentes de IA en [`../AGENTES.md`](../AGENTES.md).

Leyenda de estado: ✅ terminado · 🔄 en curso · ⏳ pendiente · ⛔ bloqueado o en pausa

---

## 1. Estado actual

| | |
|---|---|
| **Fase actual** | 0. Preparación 🔄 |
| **Fase siguiente** | 1. Login |
| **Última actualización** | 2026-10-05 |
| **Bloqueos** | El diseño detallado de la base de datos está en pausa por decisión de Chris. |

---

## 2. Fases

> El plan por fases es una **Propuesta** (plan técnico v1). Si cambia, se actualiza aquí y en `CLAUDE.md`.

| # | Fase | Estado | Historias de usuario |
|---|---|---|---|
| 0 | Preparación | 🔄 | — |
| 1 | Login | ⏳ | HU-01 |
| 2 | Clientes | ⏳ | HU-02, HU-03, HU-04 |
| 3 | Actividades, historial y agenda | ⏳ | HU-05, HU-06, HU-07 |
| 4 | Recordatorios y pantalla "Hoy" | ⏳ | HU-08, HU-10 |
| 5 | Cotizaciones | ⏳ | HU-09 |
| 6 | Reportes e importación de Excel/CSV | ⏳ | HU-11 |
| 7 | Despliegue (APK firmado, Play Store) | ⏳ | HU-12 |
| 8 | Push, offline y onboarding | ⏳ | — |

### Fase 0 · Preparación 🔄

**Objetivo:** dejar listo el repositorio, el proyecto Flutter y el entorno de desarrollo para empezar a construir funcionalidades.

- [x] Repositorio en GitHub.
- [x] Proyecto Flutter creado (`kusdy/`).
- [x] Documentación base: `CLAUDE.md`, `AGENTES.md` y este `SPECS.md`.
- [ ] Preparar el entorno de desarrollo de cada integrante (Flutter, emulador o dispositivo).
- [ ] Estructura de carpetas por *features* en `lib/` (ver `CLAUDE.md`).
- [ ] Agregar los paquetes base a `pubspec.yaml`.
- [ ] Tema y colores en `lib/app/theme.dart` (`KusdyColors`).
- [ ] Proyecto de Supabase de desarrollo.
- [ ] Tablas, RLS y migraciones SQL. ⛔ *Depende de retomar el diseño de la base de datos.*

**Criterio de terminado:** cualquier integrante puede clonar el repo, correr `flutter run` y ver la app conectada al Supabase de desarrollo.

### Fase 1 · Login ⏳

**Objetivo:** el vendedor puede iniciar y cerrar sesión con correo y contraseña, la sesión persiste y la app lo redirige al login cuando no hay sesión.

- [ ] Pantalla de login.
- [ ] Inicio y cierre de sesión con Supabase Auth.
- [ ] Sesión persistente.
- [ ] Redirección automática con `go_router`.

**Criterio de terminado:** pendiente por definir.

### Fases 2 a 8 ⏳

Se detallan con tareas y criterio de terminado cuando la fase anterior esté por cerrarse.

---

## 3. Registro de avance

Una entrada por cada cambio que se integra a `main`. La más reciente va arriba.

| Fecha | Fase | Qué se hizo | Quién | PR / Issue |
|---|---|---|---|---|
| 2026-10-05 | 0 | Documentación base: `CLAUDE.md` (contexto), `AGENTES.md` (reglas para agentes) y `SPECS.md` (este archivo). | Chris | — |
| 2026-10-05 | 0 | Proyecto Flutter inicial creado. | Chris | — |

---

## 4. Decisiones tomadas

Registro breve de cada decisión. El detalle vive en `CLAUDE.md`.

| Fecha | Decisión | Estado |
|---|---|---|
| 2026-10-05 | Backend y base de datos en Supabase (PostgreSQL con RLS). | Decisión confirmada |
| 2026-10-05 | Cada vendedor ve solo sus propios clientes. En la primera etapa solo Freddy usa Kusdy. | Decisión confirmada |
| 2026-10-05 | El diseño detallado de la base de datos queda en pausa. | Decisión confirmada |
| — | Arquitectura por *features*, Riverpod, go_router y la paleta de colores. | Propuesta |

---

## 5. Pendientes por definir

Pendientes que bloquean o afectan a las próximas fases. La lista completa está en `CLAUDE.md`.

- Dispositivos objetivo (Android, iPhone, computadora). Afecta a la fase 7.
- Diferencia entre cita y visita. Afecta a la fase 3.
- Si las cotizaciones llevan productos o solo el monto total. Afecta a la fase 5.
- Datos que salieron de los bocetos: producto de interés del cliente, "instalación" como tipo de actividad y registro de ventas cerradas.
