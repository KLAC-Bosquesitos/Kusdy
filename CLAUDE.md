# Kusdy

CRM móvil a medida para Energica Solar S.A. que centraliza clientes, llamadas, citas, visitas, cotizaciones y seguimientos de sus vendedores en una sola aplicación hecha en Flutter.

## Usuario primario

Vendedores de Energica Solar S.A. El usuario de referencia es Freddy Ramírez, Gerente de Ventas (61 años), que atiende más de 100 clientes al mes, principalmente clientes finales de productos de energía solar (sobre todo calentadores solares), y trabaja tanto dentro como fuera de la oficina.

En la primera etapa solo Freddy usará Kusdy.

## Problema

Hoy el seguimiento comercial se lleva entre Excel, una agenda física y registros manuales. Esto provoca información duplicada y desincronizada, traslado manual de datos de la agenda a Excel, dificultad para consultar información fuera de la oficina y, sobre todo, olvidos de llamadas, citas o seguimientos que terminan en clientes y ventas perdidas.

> "Si se me pasa algo representa una pérdida."

## Evidencia

En la investigación con el usuario de referencia se observó que la información está separada entre agenda y Excel, que se pierde tiempo filtrando y revisando qué clientes requieren atención, que ciertos datos solo están en la computadora de la oficina y que a veces son los propios clientes quienes tienen que recordarle al vendedor acuerdos o seguimientos.

> "Con el tiempo que ahorraría, vendería más."

## Flujo principal del MVP

Iniciar sesión -> registrar o buscar un cliente -> registrar una actividad (llamada, cita, visita) -> programar el siguiente seguimiento con recordatorio -> el seguimiento aparece en la pantalla "Hoy" y en el historial del cliente.

Detalle clave de UX: después de una llamada el flujo debe ser *Llamar -> volver a la app -> "¿Cómo te fue?" -> resultado + siguiente seguimiento en 2 toques*. Ese flujo es el corazón de "que nada se olvide".

## Alcance del MVP

### Incluye

1. Inicio de sesión de vendedores.
2. Registrar, buscar, consultar y actualizar clientes.
3. Historial por cliente (línea de tiempo de actividades y cotizaciones).
4. Registrar actividades: llamadas, citas, visitas, seguimientos y notas.
5. Programar seguimientos y recibir recordatorios.
6. Pantalla "Hoy" (dashboard básico) con vencidos, pendientes del día y próximas citas.

### No incluye todavía

1. Cotizaciones y reportes (prioridad media, fases posteriores).
2. Modo offline completo (el MVP funciona en línea).
3. Notificaciones push desde servidor (el MVP usa notificaciones locales).
4. Importación del Excel actual, exportaciones e integraciones con calendario o correo.

### Fuera de alcance

Kusdy es software a medida para una sola empresa. No es un SaaS multiempresa, no tiene planes de suscripción ni cobro por usuario, no es un ERP, inventario ni e-commerce, y no tiene un sistema complejo de roles. No se debe ampliar el sistema hacia estas áreas sin un requerimiento explícito.

## Equipo y roles

| Integrante | Rol |
|---|---|
| Andrea | Producto / PM |
| Kenneth | Arquitectura |
| Christian | UX / Investigación |
| Luis | QA / Release |

## Flujo de trabajo

Todo cambio realizado en el proyecto seguirá el siguiente proceso:

Issue -> Rama -> Pull Request -> Revisión -> Merge

Nadie trabaja directamente sobre la rama `main`.

## Estructura del repositorio

- `README.md`: presentación corta del repositorio en GitHub.
- `CLAUDE.md`: este archivo, contexto general del proyecto.
- `AGENTES.md`: instrucciones para los agentes de IA que trabajen en el proyecto.
- `kusdy/`: proyecto Flutter de la aplicación.
- `kusdy/SPECS.md`: fase actual, tareas y registro de avance.

## Decisiones técnicas

### Aplicación

**Decisión confirmada:** Flutter, con una base de código común para los distintos dispositivos.

**Propuesta** de arquitectura: organización por *features* con tres capas ligeras (`presentation`, `domain`, `data`). Las pantallas nunca llaman a Supabase directamente, siempre pasan por un repositorio.

```text
lib/
  main.dart
  app/        # router, theme
  core/       # supabase, notifications, widgets, utils
  features/
    auth/ clientes/ actividades/ cotizaciones/ dashboard/ reportes/
      data/ domain/ presentation/
```

### Manejo de estado y paquetes

**Propuesta:**

| Necesidad | Paquete |
|---|---|
| Estado | `flutter_riverpod` + `riverpod_generator` |
| Navegación | `go_router` |
| Backend | `supabase_flutter` |
| Modelos | `freezed` + `json_serializable` |
| Recordatorios | `flutter_local_notifications` |
| Caché local (fase 2) | `drift` |
| Gráficas (fase 3) | `fl_chart` |

### Backend y almacenamiento de datos

**Decisión confirmada (2026-10-05):** **Supabase** (PostgreSQL administrado) como base de datos y backend, mediante `supabase_flutter`: Auth con correo y contraseña, API (PostgREST), Row Level Security, funciones SQL vía `rpc()`, Edge Functions y Storage. No hay servidor propio. Se descartaron MySQL, Laravel o un backend propio, y Firebase/Firestore.

Reglas obligatorias (**Decisión confirmada**):

- **Row Level Security (RLS) activa en todas las tablas** (`usuario_id = auth.uid()`).
- La app solo usa la clave pública (anon / publishable). La clave `service_role` nunca va en la app, solo en Edge Functions.
- La lógica de varios pasos va en funciones SQL llamadas con `rpc()`.
- Los cambios de esquema se guardan como migraciones SQL dentro del repositorio.
- Dos proyectos de Supabase: desarrollo (plan Free) y producción (plan Pro, unos USD 25 al mes).

Visibilidad (**Decisión confirmada**): cada vendedor ve solo sus propios clientes, con sus actividades y cotizaciones. La reasignación de clientes por un administrador queda para cuando se extienda a más vendedores.

**El diseño detallado de la base de datos está en pausa por decisión de Chris.** No se empieza hasta que él lo retome.

### Recordatorios

**Propuesta:** fase 1 con notificaciones locales en el teléfono (`flutter_local_notifications`); después, push con Firebase Cloud Messaging disparado desde Supabase (`pg_cron` + Edge Function).

### Colores

**Propuesta.** Todos los colores viven en la clase `KusdyColors` de `lib/app/theme.dart` con Material 3. Nunca se escribe un `Color(0xFF...)` suelto dentro de una pantalla.

| Token | Hex |
|---|---|
| `primario` | `#1E5BC5` |
| `primarioOscuro` | `#1E4180` |
| `acento` (naranja Energica) | `#FD6512` |
| `texto` | `#15212A` |
| `fondo` | `#F5F7FA` |
| `superficie` | `#FFFFFF` |
| `vencido` | `#B3261E` |
| `exito` | `#1F6B3A` |
| `aviso` | `#8A5A00` |

Reglas: nunca texto blanco sobre naranja (se usa `#15212A`); el naranja se reserva para una sola acción por pantalla y nunca para estados; los estados siempre llevan palabra o ícono, no solo color. La paleta completa está en `kusdy/paleta-colores.md`, en los archivos del proyecto.

## Plan por fases

**Propuesta:**

0. Preparación: repositorio, estructura, Supabase de desarrollo, tablas, RLS y migraciones.
1. Login.
2. Clientes.
3. Actividades, historial y agenda.
4. Recordatorios y pantalla "Hoy".
5. Cotizaciones.
6. Reportes e importación de Excel/CSV.
7. Despliegue (APK firmado, Play Store).
8. Push, offline y onboarding.

## Pendientes por definir

- Quién paga el plan de Supabase (Energica directo o dentro del mantenimiento).
- En qué dispositivos se usará (Android, iPhone, computadora).
- Si hay diferencia real entre cita y visita.
- Si las cotizaciones llevan productos o solo el monto total.
- Cuántos vendedores usarán Kusdy.
- De los bocetos de pantallas: producto de interés del cliente, "instalación" como tipo de actividad y registro de ventas cerradas.

## Reglas para quien trabaje en el proyecto (personas y agentes de IA)

1. No inventar requerimientos: lo que no esté definido se trata como pendiente.
2. Los nombres del dominio (tablas, clases, variables de negocio) van en español: `clientes`, `actividades`, `cotizaciones`.
3. Marcar cada sugerencia como **Propuesta** o **Decisión confirmada**, sin mezclarlas.
4. Mantener el alcance de CRM interno a medida.
5. Evitar sobreingeniería (sin microservicios, colas ni arquitectura distribuida sin necesidad real).
6. Priorizar la simplicidad: pocos pasos, letra clara y navegación intuitiva para usuarios de distintas edades.
7. Si un requerimiento nuevo confirmado contradice este archivo, prevalece el requerimiento y se actualiza este archivo.
