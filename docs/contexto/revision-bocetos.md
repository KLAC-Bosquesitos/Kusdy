# Kusdy · Revisión de los bocetos (Entrega 304, Versión 2)

> Estado: **Propuesta** (2026-10-05). Base: las 6 pantallas dibujadas a mano por Chris. Aquí va qué se conserva, qué cambia al pasar a celular y qué pantallas faltan.

## Las 6 pantallas y cómo quedarían

| # | Boceto | Se conserva | Cambio propuesto y por qué |
|---|---|---|---|
| 1 | **Inicio** ("Clientes para hoy", "Clientes del mes", botones Ventas del mes / Ingresar cliente) | La idea central: al abrir la app, Freddy ve a quién atender hoy, con acciones directas (✓ hecho, mover, actualizar). | **Tablas → tarjetas.** Una tabla de 4 columnas no cabe en un celular con letra grande; cada cliente pasa a ser una tarjeta con nombre, nota y botones grandes. **Arriba, "Se te pasaron"** (lo vencido, en rojo), porque es justo lo que más le preocupa a Freddy. El número se vuelve botón **Llamar**. "Clientes del mes" se mueve a la lista de Clientes para no saturar el inicio. |
| 2 | **Ventas del mes** (gráfica, reporte, filtro por categoría) | La gráfica y el filtro. | Pasa a la pestaña **Más → Reportes**. No es algo que Freddy use cada hora, así que no ocupa lugar en el inicio. |
| 3 | **Llamada realizada** (notas, ¿agendar visita?, ¿agendar instalación?) | El flujo es el correcto: terminar una llamada y dejar programado lo siguiente. | Agregar **"¿Cómo te fue?"** con respuestas de un toque (No contestó, Interesado, Pidió cotización, No le interesa). Las fechas con **atajos** (Mañana, En 3 días, En 1 semana) y el calendario solo si hace falta, en vez de calendario + reloj siempre abiertos. |
| 4 | **Reagendar llamada** (calendario, hora, nota) | Igual. | Mismos atajos de fecha. Es la acción "mover" del inicio. |
| 5 | **Actualizar datos del cliente** | Campos: nombre, número, dirección, producto, próxima llamada. | Se diseña **junto con la 6**: es el mismo formulario. |
| 6 | **Ingresar cliente** | Campos: nombre, número, producto, dirección, nota inicial, fecha de seguimiento. | Un solo formulario para crear y editar. En Flutter es **un widget** que recibe un cliente opcional: si viene vacío, crea; si viene lleno, edita. Solo nombre y número obligatorios. |

## Pantallas que faltan (propuesta)

| Pantalla | Por qué hace falta |
|---|---|
| **Iniciar sesión** | HU-01. Sin ella no hay forma de saber qué clientes son de quién. |
| **Lista de clientes con búsqueda** | HU-03. Con los bocetos solo se llega a los clientes "de hoy" o "del mes". Si un cliente llama sin estar en la lista de hoy, Freddy no tiene cómo encontrarlo. |
| **Detalle del cliente con historial** | HU-05. Antes de llamar, Freddy necesita ver qué se habló la última vez. Hoy eso vive en su memoria o en la agenda de papel. |
| Agenda (próximos días) | ~~Opcional~~ → **2026-10-22: hace falta** (está en la barra de navegación). Propuesta en `../retro-fredy-2026-10.md`, punto 6. |

## Datos nuevos que aparecen en los bocetos

Para el hilo de planeación, porque afectan la base de datos cuando se retome:

- **Producto de interés del cliente** (panel, calentador) aparece en los formularios 5 y 6 y en "Clientes del mes".
- **Instalación** aparece como un tipo de actividad propio (boceto 3), además de llamada y visita.
- **Ventas del mes** implica registrar ventas cerradas (con producto y fecha, probablemente monto).

## Actualización 2026-10-22 · retroalimentación de Fredy

Fredy revisó las pantallas. Cambios que hay que llevar al lienzo de diseño (detalle en `../retro-fredy-2026-10.md`):

- **Lista de clientes:** los filtros dejan de ser chips; un botón "Filtrar y ordenar" abre una hoja con opciones en lista. Prioridad: "No contestaron" y ordenar por fecha.
- **Detalle del cliente:** tarjeta propia de **Comentarios** con el último comentario visible; el historial queda solo con eventos.
- **Boceto 3 (Llamada realizada):** pasa a ser dinámico: primero "¿Qué pasó?" y después opciones según el resultado (no contestó → reagendar; no le interesa → comentario; compró → registrar venta…).
- **Nueva pantalla:** Registrar venta (productos, total, método de pago).
- **Boceto 2 (Ventas del mes):** se convierte en Reportes mensual/trimestral por vendedor y equipo.
