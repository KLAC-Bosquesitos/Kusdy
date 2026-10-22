# Kusdy · Retroalimentación de Fredy (octubre 2026) y planeación siguiente

> Registrado: 2026-10-22. Fuente: Chris le mostró las pantallas a Fredy y trajo 5 puntos.
> Los **pedidos de Fredy** son requerimientos del cliente (**Decisión confirmada** en cuanto a *qué* se quiere).
> El **cómo** (pantallas, tablas, fases) es **Propuesta** hasta que Chris lo confirme.
> Este documento no contiene código ni el esquema final de la base de datos: es el análisis y el plan.

---

## Estado al cierre de la sesión (2026-10-22) · leer primero

**Para una sesión nueva:** este resumen es la versión vigente. Las secciones de cada punto explican el razonamiento y guardan las respuestas de Fredy en el orden en que llegaron; si algo de una sección choca con este resumen, manda este resumen.

**Documentos relacionados:** contexto de negocio en `../KUSDY_CONTEXT.md` (requerimientos, HU-01 a HU-18, entidades); plan técnico y modelo conceptual v2 en `plan-tecnico-v1.md` (Parte 4 y Parte 6); cambios de pantallas en `pantallas/revision-bocetos.md`.

### Decidido (por Fredy o por Chris)
- **Roles:** instalador → vendedor → jefe de sucursal (Fredy) → supervisor → gerente general. **Grupo de ventas = sucursal.** 5 sucursales, 1 supervisor para las 5. Instaladores fuera de la v1, pero en la BD.
- **Visibilidad:** vendedor ve lo suyo; jefe, lo suyo y su sucursal; supervisor, sus sucursales; gerente general, todo. Cada vendedor ve su propio reporte.
- **Administración por rol (sin `es_admin`):** usuarios los crean jefe (su sucursal), supervisor (sus sucursales, incluidos jefes) y gerente general; nadie crea a alguien de su nivel o superior. Productos: los editan jefe, supervisor y gerente. Métodos de pago casi fijos (agregar uno es excepcional). "Hasta en" y metas: gerente general.
- **Clientes:** "no contestaron" = última llamada; ordenar por próxima llamada, último contacto o fecha de registro (desplegable); filtros por mes de registro (prioritario), producto y ciudad; filtros en lista, no chips. Comentarios en tarjeta aparte + nota fija opcional.
- **Llamadas:** pantalla dinámica tras "Hecho". Resultados: no contestó, no le interesa, interesado, pidió cotización, agendar visita/instalación, compró, número equivocado, no volver a llamar (Fredy avisa si hay más). Tras 3 llamadas sin respuesta se muestra el conteo con las mismas opciones. "No le interesa" = perdido por defecto, con opción de volver a intentar.
- **Ventas:** quetzales (GTQ); métodos crédito, efectivo, tarjeta, Visacuotas; **crédito = cuotas pagadas a Energica**, y **el vendedor da seguimiento al cobro** (tabla `cuotas` con fechas de vencimiento; salen en Hoy y Agenda); número de venta **autoasignado por sucursal**; instalación **aparte, sin precio fijo y con visto bueno del jefe**; facturas físicas fuera de alcance (muy a futuro).
- **Precios:** precio de lista único para las 5 sucursales, con **bitácora** de cambios (Chris). Rango **"hasta en"** igual en las 5 sucursales, fijado y cargado en la app por el **gerente general** cada 1-2 meses; dentro del rango se vende libre; por debajo, **solicitud al jefe antes de la venta**; la solicitud aprobada **no vence** y sirve para una venta; solo el jefe autoriza; el jefe no necesita autorización para sus ventas. El precio de cada **instalación** también pasa por solicitud al jefe.
- **Agenda:** **solo vista por día** (punto 6), con datos del cliente en cada tarjeta y las **fechas de cobro de cuotas**; ver la agenda de otros vendedores es opcional (el jefe no la usa mucho).
- **Reportes:** metas mensuales por sucursal (gerente general); el monto del mes se cuenta **por lo cobrado** (pagos recibidos en el mes), no por el total vendido; **el jefe de sucursal cierra el mes** de su sucursal, con foto inmutable; trimestral = 3 cierres; exportar a **PDF**; reportes de llamadas/visitas no por ahora.

### Pendiente
- **Datos de productos** (Chris los trae; ver "Productos" en el punto 5).
- Visto bueno de Fredy al diseño completo (Chris recordó que todo lo de escalabilidad pasa primero por él).
- Contenido exacto del reporte mensual (propuesta en el punto 5, "Reportes"), cuando Fredy lo revise.
- **Diseño de la BD v2: hecho como propuesta (2026-10-22)** en `bd/diseno-bd-v2.md`, con la migración `bd/migraciones/20261022150000_esquema_inicial.sql` (probada en Postgres local). Pendiente: aprobación de Chris y aplicarla en el Supabase de desarrollo. Productos es provisional hasta tener los datos reales.
- Llevar los cambios a `CLAUDE.md` y `kusdy/SPECS.md` del repo KLAC-Bosquesitos/Kusdy (Chris hace los commits).
- Ajustar los diseños del lienzo "Kusdy pantallas": hoja de filtros, detalle con comentarios, "Hecho" dinámico, **Agenda**, registrar venta, solicitudes, reportes.

---

## Resumen en una tabla

| # | Pedido de Fredy | Pantalla que cambia | Dato nuevo o que cambia | Choca con algo ya decidido |
|---|---|---|---|---|
| 1 | Filtros: "no contestaron" y ordenar por fechas, en listado y no en burbujas | Clientes (lista) | El resultado de cada llamada debe guardarse como **opción fija**, no como texto libre | Sí: el plan tenía `resultado TEXT` |
| 2 | Comentarios en una tarjeta aparte, por fecha, con el último a mano | Detalle del cliente | **Comentarios** como registro propio, con fecha y autor | Sí: los comentarios vivían mezclados en actividades y en `clientes.notas` |
| 3 | Pantalla dinámica después de "Hecho" según lo que pasó | Llamada realizada (boceto 3) | Lista cerrada de **resultados de llamada**, y una sola operación que guarda todo | No, lo refuerza: ya estaba planeado "resultado + siguiente seguimiento en 2 toques" |
| 4 | Ventas con cliente, vendedor, datos básicos y método de pago | Registrar venta (nueva) | **Ventas**, **productos vendidos**, **pagos** y **métodos de pago** | Sí: el plan usaba la etapa `ganado` del cliente como "venta" |
| 5 | Varios vendedores a futuro, reportes mensuales y trimestrales por grupo, tabla de productos | Reportes, gestión de usuarios | **5 roles jerárquicos** y **sucursales** (confirmado 2026-10-22), **productos** | Sí: "sin roles" y "cada vendedor ve solo lo suyo" no alcanzan para los jefes que ven reportes de su grupo |

---

## Punto 1 · Filtros en la lista de clientes

### Qué pidió
Más filtros, en especial **clientes que no contestaron** y **ordenar por fechas**. Que los filtros no sean burbujas (chips) sino un **listado** fácil de recorrer.

### Pantallas (propuesta)
- Arriba de la lista quedan solo dos cosas: la **búsqueda** y un botón grande **"Filtrar y ordenar"**.
- El botón abre una **hoja inferior** (bottom sheet) con secciones en forma de lista, cada opción en su propia fila con texto grande:
  - **Mostrar** (se elige una): Todos · No contestaron · Con llamada pendiente hoy · Vencidos · Interesados · Pidieron cotización · Compraron · No interesados · Número equivocado · No volver a llamar.
  - **Producto de interés** (opcional): Calentador · Panel · … (sale de la tabla de productos).
  - **Ordenar por** (se elige una): Próxima llamada · Último contacto (más reciente primero) · Último contacto (más antiguo primero) · Fecha de registro.
- Debajo de la búsqueda, una línea de texto dice qué está activo, por ejemplo *"No contestaron · ordenados por último contacto"*, con un botón **Quitar filtros**.

**Por qué así:** con chips, Fredy tiene que leer burbujas pequeñas que se desplazan de lado; en una lista vertical cada opción ocupa una fila completa y se lee de arriba abajo, igual que en Excel. Separar *filtrar* de *ordenar* evita combinaciones confusas (ordenar siempre es una sola opción).

### Datos
- "No contestaron" solo se puede filtrar si el resultado de la llamada se guarda como **una opción de una lista cerrada** (`no_contesto`, `interesado`…). Si es texto libre ("no contestó", "no contesto", "nadie respondió"), no hay forma confiable de filtrar. Esto cambia `actividades.resultado TEXT` del plan v1 a un **tipo enumerado** (y el comentario libre se va a la tabla de comentarios, punto 2).
- Para filtrar y ordenar rápido hace falta, por cada cliente, su **último resultado**, la **fecha del último contacto** y la **fecha de la próxima llamada**. Propuesta: una **vista** en Postgres (`clientes_resumen`) que calcula esos tres datos a partir de las actividades. La app consulta la vista con `.eq()` y `.order()` de Supabase. Así no se duplica información; si algún día va lento, se agregan índices o columnas calculadas sin cambiar la app.

### Plan técnico
- Entra en la **fase 2 (Clientes)**. El filtro se hace en el servidor (consulta a Supabase), no trayendo todos los clientes al teléfono y filtrando ahí, porque con varios vendedores y cientos de clientes eso no escala.
- En Flutter, el filtro elegido es un pequeño objeto de estado (`FiltroClientes`) en un provider de Riverpod; cuando cambia, la lista se vuelve a pedir sola.

### Respuestas de Fredy (2026-10-22)
1. **"No contestaron" = su última llamada** no fue contestada.
2. **Ordenar por las tres fechas** (próxima llamada, último contacto, fecha de registro), elegidas en un **listbox** (lista desplegable).
3. **Filtros extra: ciudad, producto y mes de registro**, con **prioridad al mes**.

Ajuste a la pantalla: en la hoja de filtros, **Mes de registro** va primero después de "Mostrar", luego Producto y Ciudad; **Ordenar por** es un desplegable con las tres fechas (próxima llamada por defecto).

---

## Punto 2 · Comentarios en una tarjeta aparte

### Qué pidió
Que en la pantalla del historial del cliente los comentarios estén en **una tarjeta propia**, ordenados por fecha, con el **último comentario siempre a mano**.

### Pantallas (propuesta)
Detalle del cliente, de arriba abajo:
1. Datos del cliente y botones **Llamar / WhatsApp**.
2. **Tarjeta "Comentarios"**: muestra en grande el **último comentario** (fecha, quién lo escribió y de qué llamada salió, ej. *"21 oct · Llamada · No contestó"*). Debajo, los 2 o 3 anteriores y un botón **Ver todos** que abre la lista completa por fecha. Botón **+ Comentario** para dejar uno sin llamada.
3. **Historial** (línea de tiempo): solo eventos (llamadas, visitas, cotizaciones, ventas), cada uno con un ícono si tiene comentario, sin el texto completo para que no se sature.

**Por qué así:** antes de llamar, Fredy necesita contestar una sola pregunta: *"¿qué hablé la última vez?"*. Si el texto está mezclado en la línea de tiempo, tiene que leer todo para encontrarlo.

### Datos
Propuesta: tabla propia **`comentarios`** (cliente, autor, texto, fecha y, opcional, la actividad de la que salió).
- **Por qué tabla aparte y no un campo de la actividad:** (a) hay comentarios que no vienen de una llamada; (b) la tarjeta se llena con una consulta simple ordenada por fecha; (c) cuando haya varios vendedores y se reasigne un cliente, cada comentario conserva **quién lo escribió**.
- Con esto desaparece el tipo de actividad `nota` del plan v1. El campo `clientes.notas` queda solo para un dato fijo del cliente (ej. "pedir por el señor Juan, llamar después de las 4"), que se muestra en los datos del cliente. **Respuesta de Fredy:** se hacen ambas: los comentarios siempre, y una **nota fija opcional** por cliente.

### Plan técnico
Fase 2 (detalle del cliente) y fase 3 (los comentarios que salen de una llamada se guardan en la misma operación que el resultado).

---

## Punto 3 · Pantalla dinámica después de "Hecho"

### Qué pidió
Que la pantalla que aparece al tocar **Hecho** cambie según lo que pasó en la llamada. Ejemplos: si **no contestó**, ofrecer reagendar para más tarde u otro día; si **contestó pero no le interesa**, solo dejar un comentario.

### Pantallas (propuesta)
Es el boceto 3 ("Llamada realizada") convertido en dos pasos dentro de la misma pantalla:

**Paso 1 · "¿Qué pasó?"** (botones grandes, un toque):

| Resultado | Paso 2 que aparece |
|---|---|
| **No contestó** | Reagendar: *En 2 horas · Más tarde hoy (elegir hora) · Mañana · Otro día*. Comentario opcional. |
| **Contestó, no le interesa** | Comentario (motivo). Opción: *Volver a intentar en… (1, 3, 6 meses)* o *Cerrar cliente* (pasa a "perdido"). |
| **Interesado, llamar después** | Comentario + fecha de la siguiente llamada con atajos. |
| **Pidió cotización** | Comentario + *Crear cotización ahora* o *Recordarme hacerla* + fecha de seguimiento. |
| **Agendar visita / instalación** | Tipo, fecha y hora, dirección (precargada del cliente), comentario. |
| **Compró** | Abre **Registrar venta** (punto 4). |

Al guardar, la app vuelve a "Hoy" y el cliente desaparece de pendientes (o aparece en su nueva fecha).

### Datos
- La lista de resultados es la misma lista cerrada del punto 1. **Una sola fuente** para filtros, pantalla dinámica y reportes.
- Todo lo que hace "Guardar" (marcar la llamada como hecha con su resultado, guardar el comentario, crear la siguiente actividad, cambiar la etapa del cliente) se hace en **una función SQL** llamada con `rpc()`, en una transacción: o se guarda todo o nada. Si se cae el internet a la mitad, no queda una llamada marcada como hecha sin su siguiente seguimiento, que es justo el "se me pasó" que queremos evitar.

### Plan técnico
- Fase 3. En Flutter: un `enum ResultadoLlamada` y un `switch` que decide qué sección mostrar en el paso 2. Cada sección es un widget pequeño; así se prueba cada caso con una prueba de widget.
- Aprendizaje: estado de formulario que cambia de forma, y operaciones atómicas en el servidor.

### Respuestas de Fredy (2026-10-22)
1. **Se agregan dos resultados: "Número equivocado" y "No volver a llamar".** Si aparecen más, Fredy avisa. (Como la lista es cerrada en la base de datos, agregar uno después es una migración pequeña y aditiva.)
2. **Si no contesta 3 veces seguidas**, la pantalla muestra un mensaje con **cuántas veces se le ha llamado sin respuesta** (ej. *"Van 3 llamadas sin respuesta"*), pero **ofrece las mismas opciones** de reagendar. No bloquea nada. El conteo sale de las actividades, no hace falta guardarlo aparte.
3. **"No le interesa" se da por perdido por defecto**, pero la pantalla ofrece las dos opciones: **Cerrar cliente (perdido)**, preseleccionada, o **Volver a intentar en…**.

---

## Punto 4 · Ventas

### Qué pidió
Que las ventas guarden nombre del cliente, del vendedor, información básica de la venta y método de pago.

### Pantallas (propuesta)
**Registrar venta** (desde "Compró" en el punto 3, o desde el detalle del cliente):
- Cliente (ya viene puesto) y vendedor (el que tiene la sesión; el jefe de sucursal puede elegir a uno de su sucursal).
- Productos: elegir de la lista, cantidad y precio (precargado del catálogo, editable porque puede haber descuento).
- Total (calculado), fecha de la venta, método de pago, comentario.
- En el detalle del cliente aparece una sección **Compras**, y la venta aparece en el historial.

### Datos (modelo conceptual, no esquema final)
- **`ventas`**: cliente, vendedor, sucursal del vendedor *al momento de la venta*, fecha, total, moneda, estado (`registrada` / `anulada`), cotización de origen (opcional), comentario.
- **`venta_productos`** (líneas de la venta): producto, cantidad, **precio de lista**, **"hasta en" vigente** y **precio de venta** (copiados al vender), y la solicitud de descuento si hubo.
- **`pagos`**: venta, método de pago, monto, fecha.
- **`metodos_pago`**: catálogo precargado con **Crédito, Efectivo, Tarjeta y Visacuotas** (confirmado), con interruptor de activo.

**Decisiones explicadas:**
- **Cliente y vendedor se guardan como referencias (ids), no como texto.** El nombre se obtiene uniendo tablas. Si se escribe el nombre como texto en cada venta, un error de dedo ("Fredy" vs "Freddy") parte los reportes en dos personas.
- **El precio sí se copia en la venta.** Los precios del catálogo cambian; una venta de enero debe seguir mostrando el precio de enero.
- **Pagos en tabla aparte**, aunque la primera versión de la pantalla solo permita un método por venta. Si mañana Fredy dice "este cliente pagó la mitad en efectivo y la mitad con tarjeta" o "paga en abonos", con la tabla aparte ya está resuelto. Si el método de pago fuera una columna de `ventas`, habría que mover datos con una migración.
- **Métodos de pago como catálogo y no como lista fija en el código**, para que se pueda agregar uno sin publicar una nueva versión de la app.
- **Nunca se borra una venta**: se anula, para que los reportes ya entregados no cambien sin rastro.
- Una venta deja al cliente en etapa `ganado`, pero el cliente puede volver a comprar: por eso la venta no puede ser solo una etapa (cambio respecto al plan v1).

### Respuestas de Fredy (2026-10-22)
1. y 2. **Métodos de pago: Crédito, Efectivo, Tarjeta y Visacuotas.** Son los que se precargan en `metodos_pago`.
3. **La venta lleva un número autoasignado** (correlativo que genera la base de datos; luego se confirmó que es **por sucursal**, ver abajo). Energica lleva facturas y órdenes en papel; digitalizarlas queda para **muy a futuro** y no entra ahora.
4. **Moneda: quetzales (GTQ).** Una sola moneda, así que la columna de moneda puede quedar fija en GTQ. Zona horaria para cortar meses en reportes: `America/Guatemala`.
5. **La instalación es aparte.** Propuesta: la instalación es un ítem del catálogo de tipo **servicio** (no producto físico), que se agrega como una línea propia en la venta con su precio. Además, sigue existiendo la actividad de tipo `instalacion` para agendarla.

**Segunda ronda de respuestas (2026-10-22)**
- **Crédito = el cliente paga en cuotas directamente a Energica.** Hay que saber cuánto le falta pagar. Propuesta:
  - Cada abono es una fila en `pagos`; el **saldo** es total − suma de pagos (se calcula, no se guarda, para que nunca quede desfasado).
  - La venta a crédito guarda el **número de cuotas** y el **día de pago**, para mostrar "Cuota 3 de 12 · próxima el 15 de noviembre".
  - En el detalle del cliente y en la venta aparece **Saldo pendiente** y un botón **Registrar abono**.
  - **Confirmado: el vendedor da seguimiento al cobro.** Se agrega la tabla **`cuotas`** (venta, número de cuota, monto, fecha de vencimiento, estado). Al registrar una venta a crédito se generan las cuotas; cada abono en `pagos` se aplica a una cuota. Las cuotas próximas salen en la **Agenda** y las **atrasadas** en **Hoy**, en rojo, con botón **Registrar abono** y **Llamar**.
- **Número de venta por sucursal** (ej. `S01-000123`). Cada sucursal tiene un **código** y un **contador** propio; la función `registrar_venta` toma el siguiente número dentro de la misma transacción, así dos ventas al mismo tiempo nunca reciben el mismo número.
- **Instalación sin precio fijo:** depende de si hay que hacer estructura, nivelar el piso, etc. Propuesta: el servicio "Instalación" no tiene precio de lista ni "hasta en"; el vendedor escribe el precio y un **detalle** en la línea (ej. "incluye estructura metálica"), ~~y no aplica la regla de autorización~~. **Confirmado: el precio de la instalación sí necesita visto bueno del jefe**, siempre. Se usa la misma solicitud de los descuentos (con tipo `instalacion`), antes de la venta; el jefe no la necesita para sus propias ventas.

### Precios, rango "hasta en" y descuentos autorizados (caso de uso de Fredy, 2026-10-22)

> Reglas contadas por Fredy (confirmadas). El flujo de pantallas y las tablas son **propuesta**, pendiente de su visto bueno.

**Cómo funciona hoy en Energica**
- Cada producto tiene un **precio de lista** que casi siempre se mantiene fijo (ej. 4,900) y es igual en las 5 sucursales.
- Cada mes o cada dos meses, el **gerente general** fija para cada producto un precio **"hasta en"**: el mínimo al que se puede vender en ese periodo (ej. 4,200).
- Vender **entre el precio de lista y el "hasta en"** (4,900 a 4,200) es el rango normal del periodo.
- Vender **por debajo del "hasta en"** (ej. 4,100) es un **caso excepcional** y requiere **autorización del jefe de sucursal**.
- La autorización se pide **siempre antes de la venta**.
- **Solo el jefe de sucursal autoriza.** El supervisor podría, pero es un puesto nuevo y en la práctica siempre lo hace el jefe.
- **El jefe se autoriza a sí mismo:** cuando él vende, no necesita pedir permiso a nadie.

**Confirmado por Chris (2026-10-22):** dentro del rango (4,900 a 4,200) el vendedor vende sin pedir nada en la app, porque el rango ya viene aprobado para el periodo. Solo por debajo del "hasta en" se hace una solicitud.

**Flujo propuesto**
1. **Registrar venta:** al elegir un producto, la app muestra el precio de lista y, debajo, *"Hasta en este mes: 4,200"*. El vendedor puede poner cualquier precio dentro del rango sin pedir nada.
2. Si escribe un precio **menor al "hasta en"**, la app no deja guardar la venta y ofrece **Pedir autorización al jefe**, con un motivo.
3. **Solicitud (antes de la venta):** se crea una solicitud con cliente, producto, precio pedido y motivo, dirigida al jefe de la sucursal del vendedor.
4. El jefe la ve en **Solicitudes** (con un contador en el menú) junto con precio de lista, "hasta en", precio pedido y diferencia. Toca **Aprobar** o **Rechazar**, con comentario opcional.
5. **Aprobada:** el vendedor vuelve a Registrar venta y la app le ofrece usar ese precio autorizado para ese cliente y producto. La venta se guarda directamente como registrada y queda enlazada a la solicitud.
6. **Jefe vendiendo:** si el que registra la venta es el jefe, puede bajar del "hasta en" sin solicitud. La venta queda marcada como *"autorizada por el propio jefe"*, para que se vea en los reportes.

Como la autorización es **antes** de vender, la venta ya no necesita un estado "pendiente de autorización": o se vende dentro del rango, o se vende con una solicitud aprobada.

**Datos**
- **`productos.precio_lista`**: un solo precio, igual en las 5 sucursales. Sus cambios quedan en la bitácora.
- **`precios_hasta_en`**: producto, precio mínimo, **vigente desde**, **vigente hasta**, quién lo fijó (gerente general). Va en una tabla con fechas y no como una columna de `productos`, porque cambia cada 1 o 2 meses y hay que saber cuál estaba vigente en la fecha de cada venta. Si un producto no tiene "hasta en" vigente, el mínimo es el precio de lista: cualquier rebaja necesita autorización.
- **`venta_productos`** guarda, copiados al momento de vender: **precio de lista**, **"hasta en" vigente** y **precio de venta**, más la **solicitud** aprobada si hubo.
- **`solicitudes_descuento`**: cliente, producto, precio de lista, "hasta en", precio solicitado, motivo, quién la pidió, jefe al que va dirigida, tipo (`descuento` / `instalacion`), estado (`pendiente` / `aprobada` / `rechazada` / `usada`; **no vence**, confirmado), quién respondió, comentario y fechas.
- Las reglas van en la base de datos y no solo en la pantalla: una función SQL `registrar_venta` rechaza un precio por debajo del "hasta en" si no viene con una solicitud aprobada (o si quien vende no es jefe), y `responder_solicitud` solo deja responder al jefe de esa sucursal.
- **Por qué decidirlo ahora:** guardar el precio de lista y el "hasta en" en cada venta es estructural. Con eso, después salen reportes de **cuánto se descontó**, **cuántas ventas fueron excepcionales** y **por vendedor o sucursal**, sin tener que reconstruir los precios de ventas viejas.

**Avisos al jefe:** como el cliente suele estar esperando, la solicitud tiene que llegar rápido. En la v1 el jefe ve el contador en la app (y probablemente el vendedor también lo llame). Con el push (fase de mejoras), el aviso llega directo a su teléfono. Si en las pruebas resulta que el jefe no se entera a tiempo, el push sube de prioridad.

**Quién gestiona el "hasta en":** el gerente general. Se agrega a su tabla de permisos (pantalla **Precios del periodo**).

**Dudas que quedan para Fredy**
1. ~~Dentro del rango, ¿vende sin pedir nada?~~ → Sí, confirmado.
2. ~~¿"Hasta en" igual en las 5 sucursales?~~ → sí.
3. ~~¿La solicitud vence?~~ → no; el jefe la autoriza y el vendedor hace la venta (pasa a `usada`).
4. ~~¿Quién carga el "hasta en"?~~ → el gerente general, en la app.

---

## Punto 5 · Escalabilidad: varios vendedores, reportes y productos

### Qué pidió
Por ahora solo Fredy usa Kusdy, pero pueden entrar más empleados y no quiere tener que cambiar la base de datos después. Habló de **reportes mensuales por grupo de vendedores**, **reportes trimestrales** (a partir de tres mensuales), **tabla de productos** y **métodos de pago**.

### Una idea clave antes de diseñar: no todas las migraciones cuestan lo mismo
- **Migración aditiva** (agregar una tabla nueva, o una columna opcional): barata y segura. No rompe datos ni la app.
- **Migración estructural** (cambiar a quién pertenece un registro, mover una columna a otra tabla, convertir texto en referencias): cara, hay que transformar datos existentes y actualizar la app.

El objetivo de "no modificar la base de datos después" se cumple **acertando hoy en lo estructural**. Lo aditivo puede esperar sin riesgo. Por eso se proponen ahora solo estas piezas:

| Pieza | Por qué ahora |
|---|---|
| **Todo registro lleva su vendedor** (clientes: vendedor asignado; actividades, comentarios y ventas: quién lo hizo) | Es lo que permite que la app funcione igual con 1 o con 20 vendedores. Ya estaba en el plan; se confirma y se extiende a ventas y comentarios. |
| **Distinguir "asignado a" de "hecho por"** | Si un cliente se reasigna de vendedor, su historial y comentarios siguen diciendo quién los hizo. |
| **`perfiles.rol`** con los 5 puestos reales (ver abajo) | Cada puesto ve una porción distinta de la información. Son valores fijos, no un sistema de permisos configurable. |
| **Tabla `sucursales`** y sucursal de cada perfil (`perfiles.sucursal_id`) | Confirmado: grupo de ventas = sucursal, y es la unidad de los reportes. Agregarlo después obligaría a decidir a qué sucursal pertenecían las ventas viejas. |
| **La sucursal se guarda también en cada venta** | Si un vendedor cambia de sucursal en marzo, sus ventas de febrero deben seguir contando para la sucursal de febrero. |
| **`productos`** como catálogo con referencia desde cliente, venta y cotización | El "producto de interés" del cliente pasa de texto libre a referencia. Convertir texto a referencias después es justo una migración cara. |
| **Nunca borrar perfiles ni productos** (campo `activo`) | Las ventas viejas siguen apuntando a ellos. |
| **Fechas con zona horaria (`timestamptz`) y reportes calculados en la zona de la empresa** | Una venta a las 23:30 del 31 no debe caer en el mes siguiente. |

### Roles y sucursales (**Decisión confirmada por Fredy, 2026-10-22**)

La estructura real de Energica tiene **5 puestos**, de menor a mayor:

**Instalador → Vendedor → Jefe de sucursal → Supervisor → Gerente general**

Lo que respondió Fredy:
- **Grupo de ventas = sucursal.** Cada sucursal tiene un solo grupo: sus vendedores y su jefe. La sucursal de Fredy tiene **11 personas** en ventas (10 vendedores y él).
- Energica tiene **5 sucursales** y **un supervisor** que revisa las 5.
- Los **instaladores no usan la app en la primera versión**, pero deben quedar contemplados en la base de datos.
- **Crear usuarios** lo pueden hacer el jefe de sucursal, el supervisor o el gerente general. Las pantallas a las que entra cada uno dependen de su rol.

#### Modelo propuesto
- **`sucursales`** (es lo mismo que "grupo de ventas"): id, nombre, ciudad, **jefe** (perfil), **supervisor** (perfil), activo. No hace falta una tabla `grupos` aparte, porque grupo y sucursal son lo mismo.
- **`perfiles`**: nombre, rol (`instalador`, `vendedor`, `jefe_sucursal`, `supervisor`, `gerente_general`), **sucursal a la que pertenece** (vacía para supervisor y gerente general, que están por encima de las sucursales), activo.
- **Por qué el supervisor se guarda en cada sucursal y no "supervisor ve todo":** hoy un supervisor revisa las 5, pero si Energica abre más sucursales y contrata un segundo supervisor, cada uno tendrá las suyas. Guardarlo en la sucursal cubre los dos casos sin cambiar nada. Es el tipo de decisión estructural que conviene acertar ahora.
- **Instaladores:** el rol existe desde el inicio y las actividades de tipo `instalacion` tienen un campo opcional **instalador asignado**. Mientras no usen la app, ese campo puede quedar vacío; cuando se incorporen, solo se construyen sus pantallas.
- **Se elimina `es_admin`:** lo que cada quien puede administrar sale de su rol (tabla de abajo).
- Cada venta guarda **la sucursal del vendedor en ese momento**, por si alguien cambia de sucursal.

#### Qué ve y qué puede hacer cada rol (propuesta)
| Rol | Ve | Administra | Pantallas |
|---|---|---|---|
| Instalador *(no en v1)* | Solo sus instalaciones asignadas y la dirección/teléfono del cliente | — | Mis instalaciones (fase de mejoras) |
| Vendedor | Sus clientes, actividades, comentarios y ventas | — | Hoy, Clientes, Agenda, Registrar venta, Mi perfil |
| Jefe de sucursal (Fredy) | Lo suyo **y** todo lo de su sucursal | Usuarios **de su sucursal** (vendedores e instaladores); reasignar clientes entre vendedores de su sucursal; **productos** | Lo del vendedor + Mi sucursal (equipo), Reportes de su sucursal, Usuarios |
| Supervisor | Todo lo de las sucursales que supervisa | Usuarios de esas sucursales, incluidos los jefes; productos; **agregar un método de pago** (caso excepcional) | Lo anterior + Reportes por sucursal y consolidado, Catálogos |
| Gerente general | Todo | Todo, incluidas sucursales y supervisores | Lo anterior + Sucursales, **Precios del periodo ("hasta en")** |

Reglas que salen de la tabla:
- **Nadie crea ni edita a alguien de su mismo nivel o superior.** Un jefe no puede crear otro jefe ni un supervisor.
- **El jefe de sucursal también vende**: tiene clientes propios, igual que un vendedor (Fredy maneja más de 100).
- **La pantalla se oculta y además la base de datos lo impide.** Ocultar el botón en Flutter es comodidad; la seguridad real está en RLS. Si alguien modificara la app, la base de datos igual le negaría ver otra sucursal.

#### Cómo se implementa (resumen técnico)
- **Visibilidad:** una función SQL `puede_ver(dueño)` que responde sí cuando el dueño soy yo, o soy jefe de la sucursal del dueño, o soy supervisor de esa sucursal, o soy gerente general. Cada tabla usa esa función en su regla RLS. Agregar sucursales o personas no cambia la regla; solo agrega filas.
- **Crear usuarios:** necesita la clave de servicio de Supabase, que nunca va en la app. Se hace con una **Edge Function** `crear_usuario` que primero revisa el rol de quien la llama y si la sucursal le corresponde, y solo entonces crea la cuenta.
- **Pantallas por rol en Flutter:** `go_router` revisa el rol del perfil al navegar y redirige si no tiene acceso; los menús muestran solo lo permitido.
- **Mientras solo Fredy use la app:** se crean desde el panel de Supabase su sucursal y su perfil como jefe. La pantalla de Usuarios puede esperar a la fase de mejoras.

#### Dudas que quedan
1. ~~¿Quién edita productos y métodos de pago?~~ → **Fredy (2026-10-22):** jefe de sucursal, supervisor y gerente general **sí editan productos**. Los **métodos de pago no se editan**; solo en casos muy específicos se **agrega** uno nuevo. Propuesta: agregar o desactivar un método lo pueden hacer solo supervisor y gerente general; nadie edita ni borra uno existente, porque hay ventas que apuntan a él.
2. ~~¿Precios iguales?~~ → **Sí, iguales en las 5 sucursales.** Un solo precio por producto en la tabla `productos`; no hace falta una tabla de precios por sucursal.
3. ~~¿Reporte propio?~~ → sí, cada vendedor ve el suyo.

**Consecuencia a tener en cuenta:** como el catálogo es uno solo para las 5 sucursales, si un jefe cambia un precio, cambia para todas. **Aprobado por Chris (2026-10-22): bitácora de cambios de productos.** Una tabla **`productos_bitacora`** guarda cada cambio: producto, qué campo cambió (precio, nombre, activo…), valor anterior, valor nuevo, quién y cuándo. Se llena sola con un **trigger** de Postgres, así que no depende de que la app se acuerde de escribirla. Por qué tabla y no solo `actualizado_por`: esa columna solo recuerda el último cambio; la bitácora guarda toda la historia. Los cambios de precio serán muy excepcionales. Las ventas ya hechas no se afectan, porque copian el precio al momento de vender.

### Reportes
**Respuestas de Fredy (2026-10-22):**
- **Cada vendedor ve su propio reporte** de desempeño.
- **Hay metas mensuales**: las pone el **gerente general** y se deben alcanzar **por grupo** (sucursal).
- **Los reportes se cierran a fin de mes.**
- **Se exportan a PDF.**
- Los reportes de actividad (llamadas, visitas) **no son necesarios por ahora**.

**Diseño propuesto (cambia lo anterior):**
- **Durante el mes** el reporte se calcula en vivo con `reporte_ventas(desde, hasta, sucursal)` y muestra el **avance contra la meta** (ej. "Q 84,000 de Q 120,000 · 70%").
- **Confirmado: el monto se cuenta por lo cobrado.** El total del mes es la suma de **pagos recibidos en el mes** (contado, tarjeta, Visacuotas y abonos de crédito), no el total de las ventas. Una venta a crédito de Q 12,000 en 12 cuotas suma Q 1,000 cada mes que se cobra. El reporte también muestra, como dato secundario, cuánto se vendió (comprometido) en el mes.
- **Confirmado: el jefe de sucursal cierra el mes** de su sucursal, con un botón **Cerrar mes** en Reportes. El consolidado de las 5 se completa cuando las 5 sucursales cerraron.
- **Al cerrar el mes** se guarda una **foto** del reporte en `cierres_mensuales`: sucursal, mes, meta, total vendido, número de ventas, totales por vendedor, por producto y por método de pago, y quién y cuándo cerró. Esa foto ya no cambia.
- **El trimestral se arma con los tres cierres mensuales**, tal como lo describió Fredy, en vez de recalcular ventas. Así siempre coincide con lo que ya se entregó.
- **Después del cierre**, las ventas **y los pagos** de ese mes **no se pueden editar ni anular**. Si hay que corregir algo, se registra en el mes abierto. Lo impone la base de datos, no solo la pantalla.
- **Metas:** tabla `metas` (sucursal, mes, monto, quién la fijó). Pantalla **Metas** para el gerente general. Propuesta: el sistema reparte la meta de la sucursal solo para mostrarla; si Fredy quiere metas individuales por vendedor, se agrega después.
- **PDF:** se genera en el propio teléfono con los paquetes `pdf` y `printing` de Flutter. No hace falta servidor, y se puede compartir por WhatsApp o correo desde el menú del sistema.
- **Quién ve qué reporte:** el vendedor, el suyo; el jefe, el de su sucursal y el de cada uno de sus vendedores; el supervisor y el gerente general, por sucursal y consolidado de las 5.

**Dudas que quedan sobre reportes**
1. ~~¿Quién cierra el mes?~~ → el jefe de sucursal.
2. Contenido del reporte: propuesta = total vendido, número de ventas, avance contra la meta, por vendedor, por producto, por método de pago, descuentos excepcionales y comparación con el mes anterior. ¿Falta o sobra algo?
3. ~~¿Total vendido o cobrado?~~ → por lo cobrado.

### Productos (Chris consigue los datos)
Para diseñar la tabla hace falta saber, de los productos reales:
1. Lista de productos con su nombre comercial.
2. Categorías (calentadores, paneles, accesorios, instalación…).
3. Qué los distingue entre sí (capacidad en litros, potencia, marca, modelo).
4. Si tienen precio fijo de lista o cambia por cliente.
5. Si tienen un código interno (SKU).

Con eso se define la tabla. **No se maneja inventario** (existencias): sigue siendo un no-objetivo.

### Dudas para Fredy
1. ~~¿Cómo se forman los grupos?~~ → grupo = sucursal, con su jefe; un supervisor revisa las 5 sucursales.
2. ~~¿Quién ve los reportes?~~ → cada vendedor ve el suyo.
3. ~~¿Metas?~~ → sí, mensuales, por grupo, las fija el gerente general.
4. ~~¿Cierre?~~ → sí, a fin de mes.
5. ~~¿Exportar?~~ → PDF.
6. ~~¿Reportes de actividad?~~ → no por ahora.

---

## Punto 6 · Pantalla Agenda (pedido de Chris, 2026-10-22)

### Qué falta
La pestaña **Agenda** está en la barra de navegación (Hoy · Clientes · Agenda · Más) pero no tiene diseño. La idea de Chris: mostrar ahí más información sobre los clientes y las fechas.

### Para qué sirve (y en qué se diferencia de Hoy)
- **Hoy** = qué tengo que hacer **ahora**: lo vencido y lo de hoy, con botones de acción. Es la pantalla de trabajo.
- **Agenda** = **planear**: qué hay en cualquier otro día y qué pasó en días anteriores. Reemplaza a la agenda física de Fredy.

### Pantalla (propuesta)
1. **Confirmado por Fredy: solo vista por día.** Arriba, la fecha en grande (ej. *"Jueves 23 de octubre"*) con flechas **← →** para el día anterior y el siguiente, un botón **Hoy** para volver, y al tocar la fecha se abre el selector de fecha del sistema para saltar a un día lejano. Sin tira de semana ni calendario de mes.
2. **Debajo, la lista del día elegido**, ordenada por hora. Cada tarjeta muestra:
   - Hora, **tipo** con ícono y color (llamada, visita, cita, instalación, seguimiento).
   - **Cliente**, ciudad y **producto de interés**.
   - **Último comentario** recortado a una línea (sale de la tarjeta de comentarios del punto 2).
   - Avisos útiles: *"Van 3 llamadas sin respuesta"*, *"Saldo pendiente Q 2,400"*, *"Pidió cotización"*. (Fredy aprobó esta información; si se le ocurre más, avisa.)
   - **Cuotas por cobrar** de ese día (confirmado): tarjeta de tipo **Cobro** con cliente, *"Cuota 4 de 12 · Q 1,000"* y botones **Llamar** y **Registrar abono**.
   - Acciones: **Llamar**, **Hecho** (abre la pantalla dinámica del punto 3) y **Mover** (reagendar). Tocar la tarjeta abre el detalle del cliente.
3. **Días pasados:** muestran lo que se hizo, con su resultado (✓ Interesado, ✗ No contestó). Lo que quedó sin hacer aparece en rojo como vencido.
4. **Filtro por tipo** (una lista, igual que en Clientes): Todo · Llamadas · Visitas e instalaciones · Citas · Cobros.
5. **Para el jefe de sucursal (opcional):** Fredy dijo que no le sirve tanto, pero que estaría bien tener la opción. Va como una opción discreta en el menú (⋮) *"Ver agenda de…"*, no como selector fijo arriba, para no estorbar. Prioridad baja dentro de la fase.
6. Botón **+** para agendar una actividad nueva en el día elegido (elige cliente, tipo y hora).

### Datos
- **Ninguna tabla nueva propia de la agenda.** Es una consulta del día: `actividades` con `programada_para` en ese día, más las `cuotas` que vencen ese día, unidas al cliente y a su último comentario. Propuesta: una función `agenda(dia, vendedor)` que devuelva todo junto, para que la app haga una sola consulta por día.
- Los permisos salen solos de la regla RLS (`puede_ver`): el vendedor ve lo suyo y el jefe lo de su sucursal.
- Las fechas se muestran en la zona horaria de Guatemala, y el índice `(usuario_id, estado, programada_para)` que ya estaba en el plan hace rápida esta consulta.

### Plan técnico
- Fase 3 (Llamadas y agenda), junto con Hoy, porque las dos usan las mismas tarjetas y la misma pantalla de "Hecho". Las tarjetas se construyen como **un widget compartido** (`TarjetaActividad`) que usan Hoy, Agenda y el detalle del cliente.
- No hace falta paquete de calendario: el selector de fecha es `showDatePicker` de Flutter.

### Dudas para Fredy
### Respuestas de Fredy (2026-10-22)
1. **Solo por día.**
2. La información propuesta está bien; si se le ocurre algo más, avisa.
3. Ver la agenda de cada vendedor no le sirve tanto, pero quiere tener la opción.
4. **Las fechas de pago de las cuotas también salen en la agenda.**

---

## Cambios a decisiones anteriores

| Antes | Ahora (propuesta) | Estado |
|---|---|---|
| Sin roles; `es_admin` sí/no | 5 puestos: instalador, vendedor, jefe de sucursal, supervisor, gerente general; sin `es_admin`, la administración sale del rol | **Confirmado (Fredy, 2026-10-22)**; tabla de permisos en propuesta |
| Cada vendedor ve solo sus clientes | Se mantiene para el vendedor; el jefe ve su sucursal, el supervisor sus sucursales, el gerente general todo | Propuesta |
| `actividades.resultado` texto libre | Resultado como lista cerrada (8 valores) | Lista validada por Fredy; diseño propuesto |
| Tipo de actividad `nota` y `clientes.notas` para comentarios | Tabla `comentarios` + nota fija opcional por cliente | Fredy pidió ambas; diseño propuesto |
| Venta = etapa `ganado` | Tabla `ventas` con líneas (precio de lista, "hasta en", precio de venta), pagos/abonos y número por sucursal | Reglas de Fredy confirmadas; diseño propuesto |
| Producto de interés como texto | Referencia a `productos` | Propuesta |
| Reportes "por definir", prioridad media | Mensual por sucursal con meta, cierre a fin de mes, trimestral con 3 cierres, PDF | Requerimiento de Fredy confirmado; diseño propuesto |
| Reportes calculados siempre en vivo | En vivo durante el mes + foto en `cierres_mensuales` al cerrar | Cambió por la respuesta de Fredy |
| — | Precio "hasta en" por periodo y solicitudes de descuento al jefe | Reglas de Fredy confirmadas; diseño propuesto |

---

## Planeación siguiente (propuesta)

### Antes de programar (esta semana y la próxima)
1. ~~Preguntas a Fredy~~ → contestadas el 2026-10-22 (quedan dudas pequeñas, ver el resumen de arriba).
2. **Datos de productos.** Chris los consigue (lista del punto 5). ⏳
3. ~~Decisión de roles~~ → resuelta con Fredy: 5 puestos, grupo = sucursal, administración por rol.
4. **Ajustar los diseños** en el lienzo de pantallas: hoja de filtros, detalle con tarjeta de comentarios, flujo dinámico de "Hecho", registrar venta.
5. **Diseño de la base de datos v2** con las respuestas: diagrama, tablas, políticas RLS y la primera migración SQL. Es el paso que se había puesto en pausa; con estas respuestas ya se puede retomar.
6. **Sincronizar el repo**: llevar estos cambios a `CLAUDE.md` y `kusdy/SPECS.md` del repo (Chris hace el commit).

### Fases revisadas
| # | Fase | Qué incluye | Cambio respecto al plan v1 |
|---|---|---|---|
| 0 | Preparación | Entorno de los 4, paquetes base, Supabase de desarrollo, **BD v2 + RLS + migración inicial** | La BD deja de estar en pausa |
| 1 | Login y perfiles | Login, sesión, rol y sucursal del usuario; menús y rutas según el rol | + roles |
| 2 | Clientes | Lista con búsqueda, **hoja de filtros y orden**, formulario, **detalle con tarjeta de comentarios** e historial | + filtros (punto 1) y comentarios (punto 2) |
| 3 | Llamadas y agenda | Pantalla Hoy, **flujo dinámico de "Hecho"**, reagendar, **Agenda** (punto 6) | + puntos 3 y 6 |
| 4 | Recordatorios | Notificaciones locales | igual |
| 5 | **Productos y ventas** | Catálogo de productos con bitácora, métodos de pago, precios "hasta en", registrar venta, solicitudes de descuento al jefe, abonos de crédito, compras del cliente | **Nueva** (punto 4) |
| 6 | Cotizaciones | Cotizaciones con productos del catálogo | Ahora reutiliza productos |
| 7 | **Reportes** | Metas, reporte mensual en vivo contra la meta, cierre de mes, trimestral con 3 cierres, PDF; vistas por rol | Más concreta (punto 5) |
| 8 | Despliegue | Supabase producción, APK firmado | igual |
| 9 | Mejoras | Push, offline, onboarding, importar Excel, gestión de usuarios desde la app | — |

**Por qué ventas antes que cotizaciones:** los reportes que pidió Fredy salen de las ventas, y "Compró" es uno de los resultados de la llamada. Las cotizaciones pueden esperar sin bloquear nada.

**Por qué la gestión de usuarios desde la app va al final:** mientras Fredy sea el único usuario, los vendedores nuevos se pueden crear desde el panel de Supabase. Lo importante es que la base de datos ya los soporte.

---

## Preguntas para Fredy (para llevar impresas)

**Clientes y llamadas**
1. ~~"No contestaron"~~ → solo la última llamada.
2. ~~"Ordenar por fecha"~~ → las tres, en un listbox.
3. ~~Otros filtros~~ → ciudad, producto y mes de registro; prioridad al mes.
4. ~~Resultados que faltan~~ → número equivocado y no volver a llamar; si hay más, Fredy avisa.
5. ~~3 sin contestar~~ → mensaje con el conteo y las mismas opciones.
6. ~~No le interesa~~ → perdido por defecto, con opción de volver a intentar.
7. ~~Nota fija~~ → sí, opcional, además de los comentarios.

**Ventas**
8. y 9. ~~Métodos de pago~~ → crédito, efectivo, tarjeta, Visacuotas. ~~¿Crédito en cuotas a Energica?~~ → sí.
10. ~~Número~~ → autoasignado, por sucursal; facturas en papel quedan para muy a futuro.
11. ~~Moneda~~ → quetzales.
12. ~~Instalación~~ → aparte, sin precio fijo (depende de estructura, nivelación, etc.).

**Equipo y reportes**
13. ~~Grupos~~ → resuelto: grupo = sucursal; un supervisor para las 5. Productos: los edita el jefe también; métodos de pago casi fijos; precios iguales en las 5 sucursales.
14. ~~Reporte propio~~ → sí, cada vendedor ve el suyo.
14b. ~~Instaladores~~ → no en la v1; quedan en la base de datos.
15. ~~Metas~~ → mensuales por grupo, del gerente general.
16. ~~Cierre~~ → a fin de mes.
17. ~~Exportar~~ → PDF.
18. ~~Reportes de actividad~~ → no por ahora.

**Dudas pequeñas (todas resueltas el 2026-10-22):** el jefe de sucursal cierra el mes · el reporte cuenta lo cobrado · el vendedor da seguimiento al cobro · la instalación necesita visto bueno del jefe · el "hasta en" es igual en las 5 sucursales · la solicitud aprobada no vence · el gerente general carga el "hasta en".
