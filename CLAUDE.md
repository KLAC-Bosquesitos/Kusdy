# Kusdy

CRM móvil a medida para Energica Solar S.A. que centraliza clientes, llamadas, citas, visitas, ventas y seguimientos de sus vendedores en una sola aplicación hecha en Flutter, con Supabase como backend.

> **Última actualización: 2026-10-22**, después de la retroalimentación de Freddy y de aplicar la base de datos v2 en Supabase. Si algo de este archivo choca con `docs/contexto/retro-fredy-2026-10.md` (sección "Estado al cierre de la sesión"), manda la retro; avisa para corregir este archivo.

## Dónde está cada cosa

| Archivo | Qué tiene |
|---|---|
| `CLAUDE.md` | Este archivo: producto, decisiones, arquitectura, base de datos resumida y reglas. |
| `AGENTES.md` | Cómo debe trabajar un agente de IA en este repo. |
| `kusdy/SPECS.md` | Fase actual, tareas, registro de avance y decisiones tomadas. |
| `docs/bd/diseno-bd-v2.md` | Diseño de la base de datos: tablas, por qué están así, permisos RLS, funciones por fase. |
| `supabase/migrations/` | Migraciones SQL **ya aplicadas** en Supabase de desarrollo. |
| `supabase/pruebas/` | Pruebas SQL de permisos y reglas (se corren en un Postgres local). |
| `docs/contexto/retro-fredy-2026-10.md` | Pedidos de Freddy punto por punto, con el diseño de cada pantalla nueva (filtros, comentarios, "Hecho" dinámico, ventas, Agenda). |
| `docs/contexto/KUSDY_CONTEXT.md` | Contexto de negocio completo: persona, historias de usuario HU-01 a HU-18, entidades, principios de UX. |
| `docs/contexto/revision-bocetos.md` | Qué se conserva y qué cambia de los bocetos a mano. |
| `docs/contexto/paleta-colores.md` | Paleta completa y reglas de contraste. |
| `docs/bitacora-ia.md` | Bitácora de uso de IA del curso. |

## Usuario primario

Vendedores de Energica Solar S.A. El usuario de referencia es Freddy Ramírez, **jefe de sucursal** (61 años), que atiende más de 100 clientes al mes, principalmente clientes finales de calentadores solares, y trabaja dentro y fuera de la oficina. Su sucursal tiene 11 personas en ventas (10 vendedores y él).

En la primera etapa **solo Freddy usará Kusdy**, pero la base de datos ya soporta 5 sucursales y 5 roles.

## Problema

Hoy el seguimiento comercial se lleva entre Excel, una agenda física y registros manuales: información duplicada, traslado manual de datos, dificultad para consultar fuera de la oficina y, sobre todo, olvidos de llamadas, citas o seguimientos que terminan en ventas perdidas.

> "Si se me pasa algo representa una pérdida."
>
> "Con el tiempo que ahorraría, vendería más."

## Flujo principal

Iniciar sesión → registrar o buscar un cliente → llamar → "¿Qué pasó?" → resultado + siguiente seguimiento en 2 toques → el seguimiento aparece en **Hoy**, en la **Agenda** y en el historial del cliente.

Ese flujo es el corazón de "que nada se olvide".

## Decisiones confirmadas (2026-10-22)

Confirmadas por Freddy o por Chris. El detalle y el razonamiento están en `docs/contexto/retro-fredy-2026-10.md`.

- **Roles (5 puestos):** instalador → vendedor → jefe de sucursal (Freddy) → supervisor → gerente general. **Grupo de ventas = sucursal.** 5 sucursales y 1 supervisor para las 5. Los instaladores no usan la app en la v1, pero ya existen en la BD.
- **Visibilidad:** el vendedor ve lo suyo; el jefe, lo suyo y lo de su sucursal; el supervisor, sus sucursales; el gerente general, todo. Cada vendedor ve su propio reporte. El jefe también vende y tiene clientes propios.
- **Administración por rol (no hay `es_admin`):** usuarios los crean jefe (su sucursal), supervisor (sus sucursales, incluidos jefes) y gerente general; nadie crea a alguien de su nivel o superior. Productos: los editan jefe, supervisor y gerente. Métodos de pago casi fijos (agregar uno es excepcional: supervisor o gerente). "Hasta en" y metas: gerente general.
- **Clientes:** filtros en una hoja con opciones en lista (**no chips**): "No contestaron" (= la **última** llamada no se contestó), mes de registro (prioritario), producto y ciudad. Ordenar por próxima llamada, último contacto o fecha de registro (desplegable).
- **Comentarios:** tarjeta propia en el detalle del cliente, con el último a la vista. **Su autor puede editarlos** (queda el texto anterior y la app muestra "(editado)"); no se borran. Además, una **nota fija** opcional por cliente.
- **Llamadas:** pantalla dinámica tras "Hecho". Resultados (lista cerrada): no contestó, no le interesa, interesado, pidió cotización, agendar visita/instalación, compró, número equivocado, no volver a llamar. Tras 3 llamadas seguidas sin respuesta se muestra "Van 3 llamadas sin respuesta" con las mismas opciones (no bloquea). "No le interesa" = perdido por defecto, con opción "Volver a intentar en…".
- **Ventas:** en quetzales (GTQ), zona horaria `America/Guatemala`. Métodos: Crédito, Efectivo, Tarjeta, Visacuotas. **Crédito = cuotas pagadas a Energica** y el vendedor da seguimiento al cobro (las cuotas salen en Hoy y Agenda). Número de venta **autoasignado por sucursal** (ej. `S01-000123`). La instalación se cobra aparte, sin precio fijo. Facturas fuera de alcance.
- **Precios y descuentos:** precio de lista único para las 5 sucursales, con bitácora de cambios. El gerente general fija cada 1-2 meses un precio **"hasta en"** (mínimo del periodo). Entre lista y "hasta en" se vende libre. Por debajo, **solicitud al jefe antes de la venta**; la aprobada no vence y sirve para una venta. Solo el jefe autoriza; el jefe no necesita autorización para sus ventas. El precio de cada instalación también pasa por solicitud al jefe.
- **Agenda:** **solo vista por día**, con datos del cliente en cada tarjeta y las **fechas de cobro de cuotas**. Ver la agenda de otro vendedor es opcional y de baja prioridad.
- **Reportes:** metas mensuales por sucursal (gerente general). El mes se cuenta **por lo cobrado** (pagos recibidos), no por lo vendido. **El jefe cierra el mes** de su sucursal y queda una foto inmutable; trimestral = 3 cierres; exportar a PDF. Reportes de llamadas/visitas no por ahora.
- **Backend: Supabase** (decisión del 2026-10-05). Ver la sección "Supabase".

## Alcance

### Incluye (por fases, ver abajo)

Login y perfiles con rol · clientes con filtros, comentarios e historial · llamadas con resultado y siguiente seguimiento · Hoy y Agenda · recordatorios locales · productos, ventas, cuotas, abonos y solicitudes de precio · reportes mensuales y trimestrales.

### No incluye todavía

Cotizaciones (fase 6; sus ítems siguen sin definir) · modo offline completo · push desde servidor (el MVP usa notificaciones locales) · importar el Excel actual, exportaciones distintas del PDF de reportes e integraciones con calendario o correo · gestión de usuarios desde la app (mientras solo Freddy la use, se crean desde el panel de Supabase) · pantallas de instalador.

### Fuera de alcance

Kusdy es software a medida para una sola empresa. No es un SaaS multiempresa, no tiene suscripciones ni cobro por usuario, no es un ERP, inventario, facturación ni e-commerce. Los 5 roles son puestos fijos, no un sistema de permisos configurable. No se amplía hacia estas áreas sin un requerimiento explícito.

## Equipo y roles

| Integrante | Rol |
|---|---|
| Andrea | Producto / PM |
| Kenneth | Arquitectura |
| Christian (Chris) | UX / Investigación |
| Luis | QA / Release |

## Flujo de trabajo

Issue → Rama → Pull Request → Revisión → Merge. Nadie trabaja directamente sobre `main`. La CI (`.github/workflows/`) corre `flutter analyze` y `flutter test`.

## Arquitectura de la app

**Decisión confirmada:** Flutter, una base de código común.

**Propuesta (en uso desde el Lab S14):** organización por *features* con tres capas ligeras. Las pantallas nunca llaman a Supabase directamente; siempre pasan por un repositorio.

```text
kusdy/lib/
  main.dart
  app/          # app.dart, router.dart (go_router), theme.dart (KusdyColors)
  core/
    supabase/       # inicialización del cliente
    notifications/  # recordatorios locales
    widgets/        # EstadoCargando, EstadoError, EstadoVacio, TarjetaActividad...
    utils/          # fechas en hora de Guatemala, formato de quetzales
  features/
    auth/ clientes/ actividades/ hoy/ agenda/ ventas/ productos/ solicitudes/ reportes/
      data/          # repositorio real (Supabase) y falso (pruebas), modelos JSON
      domain/        # entidades y la interfaz del repositorio
      presentation/  # pantallas, widgets y providers de Riverpod
```

- `domain/` define la interfaz (`ClientesRepository`); `data/` tiene la implementación con Supabase y una **falsa** para pruebas y para trabajar sin red. Ya existe `clientes_repository_falso.dart`.
- Los estados de carga, error y vacío se muestran con los widgets compartidos de `core/widgets/` y `AsyncValue` de Riverpod.
- *Use cases* solo donde hay lógica real; Clean Architecture completa sería sobreingeniería.
- Las tarjetas de actividad son **un widget compartido** (`TarjetaActividad`) que usan Hoy, Agenda y el detalle del cliente.
- Lo de varios pasos (resultado de llamada, registrar venta) se hace con una sola llamada `rpc()` a una función SQL, nunca en pasos sueltos desde la app.
- Pantallas por rol: `go_router` revisa el rol del perfil y redirige; los menús muestran solo lo permitido. Ocultar es comodidad; la seguridad real está en RLS.

### Paquetes

| Necesidad | Paquete | Estado |
|---|---|---|
| Estado | `flutter_riverpod` (+ `riverpod_generator` propuesto) | `flutter_riverpod` ya instalado |
| Navegación | `go_router` | Propuesta |
| Backend | `supabase_flutter` | Decisión confirmada |
| Modelos | `freezed` + `json_serializable` | Propuesta |
| Recordatorios | `flutter_local_notifications` | Propuesta (fase 4) |
| Fechas y moneda | `intl` | Propuesta |
| PDF de reportes | `pdf` + `printing` | Propuesta (fase 7) |
| Gráficas | `fl_chart` | Propuesta (fase 7) |
| Caché offline | `drift` | Propuesta (fase 9) |

## Pantallas

Navegación inferior con 4 pestañas grandes: **Hoy · Clientes · Agenda · Más**. Detalle de cada una en `docs/contexto/retro-fredy-2026-10.md` y `docs/contexto/revision-bocetos.md`. Todo es **Propuesta** salvo lo marcado arriba como confirmado.

| Pantalla | Contenido | Fase |
|---|---|---|
| Login | Correo y contraseña. | 1 |
| **Hoy** | Arriba "Se te pasaron" (vencidos, en rojo, con palabra o ícono), luego lo de hoy y las cuotas atrasadas. Tarjetas con botones **Llamar**, **Hecho**, **Mover**. | 3 |
| **Clientes** | Búsqueda por nombre o teléfono y botón **"Filtrar y ordenar"** que abre una hoja con opciones en lista. Consulta la vista `clientes_resumen`. | 2 |
| Detalle del cliente | Datos, Llamar / WhatsApp / Mapa, etapa, nota fija, **tarjeta de Comentarios** (último grande, "+ Comentario", editar los propios), **historial solo con eventos**, compras y saldo pendiente. | 2 |
| Formulario de cliente | Un solo widget para crear y editar (recibe un cliente opcional). Solo nombre y teléfono obligatorios. | 2 |
| **Llamada realizada (dinámica)** | Paso 1 "¿Qué pasó?" con botones grandes; paso 2 según el resultado (reagendar con atajos En 2 horas / Mañana / Otro día, comentario, agendar visita o instalación, registrar venta). Un `enum ResultadoLlamada` y un widget por caso. | 3 |
| **Agenda** | Solo por día: fecha grande con ← → , botón Hoy y `showDatePicker`. Lista del día por hora con actividades y **cobros de cuotas**; cada tarjeta con tipo, cliente, ciudad, producto, último comentario y avisos. Filtro por tipo. Botón + para agendar. | 3 |
| Registrar venta | Cliente, productos con cantidad y precio (muestra "Hasta en este mes"), total, método de pago, cuotas si es crédito. Si el precio baja del "hasta en", ofrece **Pedir autorización al jefe**. | 5 |
| Solicitudes (jefe) | Contador en el menú; aprobar o rechazar con comentario. | 5 |
| Reportes (en Más) | Mensual contra la meta, cierre de mes, trimestral, PDF; por vendedor y por sucursal según el rol. | 7 |
| Productos, Precios del periodo, Usuarios, Sucursales (en Más) | Según el rol (ver la tabla de roles en la retro, punto 5). | 5 / 9 |

## Supabase

**Decisión confirmada (2026-10-05):** Supabase (PostgreSQL administrado) mediante `supabase_flutter`: Auth con correo y contraseña, API (PostgREST), Row Level Security, funciones SQL vía `rpc()`, Edge Functions y Storage. No hay servidor propio.

### Reglas obligatorias

- **RLS activa en todas las tablas.** Toda la seguridad sale de la función `puede_ver(dueño)` = *es mío · soy jefe o supervisor de la sucursal del dueño · soy gerente general*.
- Las políticas son solo para usuarios con sesión (`authenticated`); sin sesión no se ve nada.
- La app solo usa la clave **publishable**. La `service_role` / secret **nunca** va en la app, en el repo ni en la documentación; solo en Edge Functions.
- Lo de varios pasos va en funciones SQL llamadas con `rpc()` (una transacción: todo o nada).
- Ventas, líneas, cuotas, pagos, responder solicitudes y cerrar el mes **no se escriben directo**: solo con funciones.
- Nada se borra: clientes con `eliminado_en`; perfiles, productos y métodos con `activo`; ventas con estado `anulada`.
- Dinero en `numeric(12,2)` y en GTQ. Fechas en `timestamptz`; los meses se cortan en `America/Guatemala`.
- Todo cambio de esquema es una **migración nueva** en `supabase/migrations/`. Nunca se edita una migración ya aplicada ni se cambian tablas a mano desde el panel.

### Proyecto de desarrollo

| Dato | Valor |
|---|---|
| Proyecto | `kusdy-dev` (plan Free, región `us-east-1`) |
| URL | `https://dygbykkhdnpuoapbkaip.supabase.co` |
| Project ref | `dygbykkhdnpuoapbkaip` |
| Llave publishable (pública, va en la app) | `sb_publishable_YaPNdRVLAVi4pybPUrrd4Q_M3gDXuWQ` |

**Propuesta:** pasar URL y llave con `--dart-define` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`) para poder cambiar a producción sin tocar código. Producción será otro proyecto (Pro, unos USD 25 al mes) con las mismas migraciones.

Migraciones aplicadas en kusdy-dev (los nombres de archivo usan la misma versión que el servidor):

1. `20261022152936_esquema_inicial.sql`: las 17 tablas, 2 vistas, funciones de permisos, triggers y RLS.
2. `20261022153519_ajustes_advisors.sql`: endurece funciones y políticas según el Advisor; no cambia tablas.

La base está **vacía** salvo los 4 métodos de pago y el servicio "Instalación". Falta crear a mano el usuario de Freddy, la sucursal `S01` y su perfil `jefe_sucursal` (ver `docs/bd/diseno-bd-v2.md`, sección 6).

### Esquema (resumen)

Detalle completo en `docs/bd/diseno-bd-v2.md`; el SQL manda.

| Grupo | Tablas |
|---|---|
| Organización | `sucursales` (codigo, jefe_id, supervisor_id, contador de ventas), `perfiles` (mismo id que el usuario de Auth; nombre, telefono, rol, sucursal_id, activo) |
| Catálogos | `productos` (**provisional**: tipo producto/servicio, precio_lista), `productos_bitacora` (trigger), `precios_hasta_en` (vigente_desde/hasta, sin traslapes), `metodos_pago` (es_credito) |
| Clientes | `clientes` (vendedor_id, nombre, telefono, telefono_alt, correo, direccion, ciudad, tipo, etapa, producto_interes_id, origen, nota_fija, creado_por, eliminado_en), `actividades` (cliente_id, usuario_id, tipo, programada_para, recordar_en, realizada_en, estado, resultado, instalador_id, actividad_origen_id), `comentarios` (autor_id, actividad_id, texto, editado_en), `comentarios_ediciones` |
| Autorizaciones | `solicitudes_precio` (tipo descuento/instalacion, estado pendiente/aprobada/rechazada/usada) |
| Ventas | `ventas` (numero por sucursal, sucursal_id copiada, estado registrada/anulada), `venta_lineas` (precio_lista y hasta_en copiados, precio_unitario, subtotal), `cuotas`, `pagos` (fecha_pago) |
| Reportes | `metas`, `cierres_mensuales` (bloquean ventas y pagos del mes cerrado) |
| Vistas | `clientes_resumen` (ultimo_resultado, ultimo_contacto, proxima_llamada, intentos_sin_respuesta, no_contesto), `cuotas_estado` (pagado, saldo, pagada, atrasada) |

Listas cerradas (enums de Postgres; en Dart van como `enum` con los mismos valores):

- `rol_usuario`: `instalador`, `vendedor`, `jefe_sucursal`, `supervisor`, `gerente_general`
- `tipo_actividad`: `llamada`, `cita`, `visita`, `instalacion`, `seguimiento`
- `estado_actividad`: `pendiente`, `completada`, `cancelada`
- `resultado_llamada`: `no_contesto`, `no_interesado`, `interesado`, `pidio_cotizacion`, `agendo_visita`, `compro`, `numero_equivocado`, `no_volver_a_llamar`
- `etapa_cliente`: `prospecto`, `contactado`, `cotizado`, `ganado`, `perdido` (propuesta, sin validar con Freddy)
- `tipo_cliente`: `final`, `mayorista`
- `tipo_producto`: `producto`, `servicio` · `tipo_solicitud`: `descuento`, `instalacion` · `estado_solicitud`: `pendiente`, `aprobada`, `rechazada`, `usada` · `estado_venta`: `registrada`, `anulada`

### Funciones que faltan (migraciones aditivas por fase)

| Fase | Función | Qué hace |
|---|---|---|
| 1 | Edge Function `crear_usuario` | Crea usuario en Auth y su perfil, validando el rol de quien llama (fase 9 en la app; antes, desde el panel). |
| 3 | `registrar_resultado_llamada(...)` | Completa la llamada con su resultado, guarda el comentario, crea la siguiente actividad y ajusta la etapa. |
| 3 | `agenda(dia, vendedor)` | Actividades y cuotas del día con cliente y último comentario, en una sola consulta. |
| 5 | `registrar_venta(...)`, `responder_solicitud(...)`, `registrar_abono(...)`, `anular_venta(...)` | Ventas con validación de precios, número por sucursal, cuotas y pagos. |
| 7 | `reporte_ventas(desde, hasta, sucursal)`, `cerrar_mes(sucursal, mes)` | Reporte en vivo y cierre de mes. |

## Recordatorios

**Propuesta:** fase 4 con notificaciones locales (`flutter_local_notifications`) a partir de `actividades.recordar_en`; después, push con Firebase Cloud Messaging disparado desde Supabase (`pg_cron` + Edge Function).

## Colores y UX

**Propuesta.** Todos los colores viven en `KusdyColors` (`kusdy/lib/app/theme.dart`) con Material 3. Nunca se escribe un `Color(0xFF...)` suelto en una pantalla.

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

Reglas: nunca texto blanco sobre naranja (se usa `#15212A`); el naranja se reserva para una sola acción por pantalla y nunca para estados; los estados siempre llevan palabra o ícono, no solo color. Paleta completa en `docs/contexto/paleta-colores.md`.

Pensando en un usuario de 61 años: letra grande, botones grandes, pocos pasos, tarjetas en vez de tablas, atajos de fecha en vez de calendario abierto, y fechas en hora de Guatemala con formato en español.

## Plan por fases

**Propuesta revisada (2026-10-22).**

| # | Fase | Qué incluye |
|---|---|---|
| 0 | Preparación | Entorno, paquetes base, Supabase de desarrollo, **BD v2 + RLS + migraciones** (aplicadas). |
| 1 | Login y perfiles | Login/logout, sesión persistente, redirección con `go_router`, rol y sucursal del usuario, menús según rol. |
| 2 | Clientes | Lista con búsqueda, hoja de filtros y orden, formulario, detalle con tarjeta de comentarios e historial. |
| 3 | Llamadas y agenda | Hoy, "Hecho" dinámico, reagendar, Agenda por día. |
| 4 | Recordatorios | Notificaciones locales. |
| 5 | Productos y ventas | Catálogo con bitácora, "hasta en", registrar venta, solicitudes al jefe, cuotas y abonos. |
| 6 | Cotizaciones | Con productos del catálogo. |
| 7 | Reportes | Metas, mensual en vivo, cierre de mes, trimestral, PDF, vistas por rol. |
| 8 | Despliegue | Supabase producción, APK firmado, pruebas con Freddy. |
| 9 | Mejoras | Push, offline, onboarding, importar Excel, gestión de usuarios desde la app. |

## Pendientes por definir

- **Datos reales de productos** (Chris los trae). La tabla `productos` es provisional.
- Visto bueno de Freddy al diseño completo (todo lo de escalabilidad pasa primero por él).
- Contenido exacto del reporte mensual.
- Si hay diferencia real entre cita y visita (hoy son dos tipos).
- Etapas del cliente (`prospecto`… `perdido`) sin validar con Freddy.
- Qué llevan las cotizaciones.
- En qué dispositivos se usará (Android, iPhone, computadora).
- Quién paga el plan de Supabase de producción.
- Ajustar los diseños del lienzo de pantallas (filtros, comentarios, "Hecho" dinámico, Agenda, ventas, solicitudes, reportes).

## Reglas para quien trabaje en el proyecto (personas y agentes de IA)

1. No inventar requerimientos: lo que no esté definido se trata como pendiente.
2. Los nombres del dominio (tablas, clases, variables de negocio) van en español: `clientes`, `actividades`, `ventas`.
3. Marcar cada sugerencia como **Propuesta** o **Decisión confirmada**, sin mezclarlas.
4. Mantener el alcance de CRM interno a medida.
5. Evitar sobreingeniería (sin microservicios, colas ni arquitectura distribuida sin necesidad real).
6. Priorizar la simplicidad: pocos pasos, letra clara y navegación intuitiva para usuarios de distintas edades.
7. Si un requerimiento nuevo confirmado contradice este archivo, prevalece el requerimiento y se actualiza este archivo.
