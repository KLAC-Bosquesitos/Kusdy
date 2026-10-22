# KUSDY — Contexto Maestro del Proyecto

> **Propósito de este archivo:** servir como fuente de contexto compartida para personas y agentes de IA que participen en el análisis, diseño, desarrollo, pruebas, documentación y evolución de Kusdy.
>
> Este documento debe tratarse como **contexto funcional y de negocio**, no como una especificación técnica cerrada. Cuando un dato aparezca como **pendiente por definir**, ningún agente debe inventarlo ni asumirlo sin validación.

> **Estado al 2026-10-22 (leer primero):** Freddy revisó las pantallas y dio retroalimentación; luego respondió las preguntas de seguimiento. El resumen vigente de lo decidido y lo pendiente está en `kusdy/retro-fredy-2026-10.md`, sección "Estado al cierre de la sesión". El modelo conceptual de datos v2 (propuesta) está en `kusdy/plan-tecnico-v1.md`, Parte 4. El diseño detallado de la base de datos aún no se ha escrito; los datos reales de productos los trae Chris. Todo el diseño de escalabilidad (roles, sucursales, reportes) está pendiente del visto bueno final de Freddy.

---

## 1. Identidad del proyecto

**Nombre del sistema:** Kusdy  
**Tipo de producto:** CRM / sistema de gestión comercial a medida  
**Cliente:** Energica Solar S.A.  
**Modelo de entrega:** software desarrollado específicamente para la empresa  
**Modelo comercial:** pago único / licencia de uso del sistema  
**Usuarios principales:** vendedores de Energica Solar S.A.

Kusdy nace como una solución para centralizar la información comercial de Energica Solar S.A. y reducir la dependencia de herramientas separadas como Excel y agendas físicas.

La aplicación debe ayudar a los vendedores a mantener control sobre clientes, llamadas, citas, cotizaciones, seguimientos e historial comercial desde una sola herramienta.

---

## 2. Problema que Kusdy busca resolver

Actualmente parte del seguimiento comercial se realiza utilizando una combinación de:

- Excel.
- Agenda física.
- Registros manuales.
- Información almacenada de forma separada.
- Seguimientos que dependen de la memoria o revisión manual.

Esto provoca problemas como:

- Duplicación de información.
- Necesidad de trasladar datos manualmente de la agenda a Excel.
- Información desincronizada.
- Dificultad para consultar datos cuando el vendedor está fuera de la oficina.
- Riesgo de olvidar llamadas, citas o seguimientos.
- Pérdida de tiempo revisando manualmente qué clientes requieren atención.
- Posibles pérdidas de clientes y ventas por falta de seguimiento oportuno.

La frase que mejor resume este problema desde la perspectiva del usuario es:

> **“Si se me pasa algo representa una pérdida.”**

---

## 3. Usuario de referencia

### Freddy Ramírez

**Edad:** 61 años  
**Cargo:** Jefe de sucursal (área de ventas; su sucursal tiene 11 personas en ventas: 10 vendedores y él)  
**Empresa:** Energica Solar S.A.  
**Área:** Ventas  
**Sector:** Energía solar  
**Productos principales:** productos relacionados con energía solar, especialmente calentadores solares.

### Perfil de trabajo

Freddy:

- Atiende clientes de distintas ubicaciones.
- Trabaja principalmente con clientes finales.
- Atiende mayoristas solo ocasionalmente.
- Puede manejar más de 100 clientes durante un mes.
- Utiliza Excel y agenda física para organizar información.
- Revisa clientes y seguimientos de manera constante.
- Necesita trabajar tanto dentro como fuera de la oficina.
- Está dispuesto a adoptar una nueva herramienta si esta simplifica su trabajo.

### Necesidad central

El usuario necesita una herramienta sencilla y práctica que le permita mantener la información comercial actualizada desde distintos dispositivos y evitar depender de múltiples medios de registro.

---

## 4. User Persona — síntesis

### Descripción, rasgos y atributos

- Gerente de ventas con experiencia en atención y seguimiento de clientes.
- Comercializa soluciones relacionadas con energía solar.
- Atiende clientes de diferentes ubicaciones.
- Su cartera está compuesta principalmente por clientes finales.
- Actualmente combina Excel y agenda física.
- Maneja un volumen importante de clientes.
- Está dispuesto a adaptarse a un sistema nuevo.
- Necesita facilidad de uso y acceso fuera de la oficina.

### Tareas frecuentes

- Registrar información de clientes.
- Registrar números de contacto.
- Consultar clientes.
- Revisar llamadas pendientes.
- Realizar llamadas de seguimiento.
- Programar visitas.
- Programar citas.
- Registrar cotizaciones.
- Consultar cotizaciones.
- Actualizar información de clientes.
- Dar seguimiento al proceso comercial.
- Revisar actividades pendientes.
- Organizar clientes y actividades por periodos.

### Dolores

- Información separada entre agenda y Excel.
- Duplicación de trabajo.
- Traslado manual de información.
- Riesgo de olvidar seguimientos.
- Dificultad para mantener la información sincronizada.
- Pérdida de tiempo filtrando y revisando información.
- Dependencia de la computadora de la oficina para acceder a ciertos datos.
- Clientes que en ocasiones deben recordar acuerdos o seguimientos.
- Riesgo de perder ventas o clientes.

### Generadores de valor

Kusdy debería permitir:

- Centralizar la información.
- Consultar datos desde distintos dispositivos.
- Saber rápidamente qué cliente requiere seguimiento.
- Recibir recordatorios.
- Mantener historial de cada cliente.
- Evitar registrar información varias veces.
- Reducir olvidos.
- Ahorrar tiempo administrativo.
- Facilitar el trabajo fuera de la oficina.
- Dedicar más tiempo a vender.

Frase representativa:

> **“Con el tiempo que ahorraría, vendería más.”**

---

## 5. Objetivo general del producto

Desarrollar una aplicación CRM a medida para Energica Solar S.A. que centralice la gestión de clientes y actividades comerciales, facilite el seguimiento de oportunidades de venta y reduzca las pérdidas provocadas por olvidos, registros dispersos o falta de información actualizada.

---

## 6. Propuesta de valor

La propuesta principal de Kusdy es:

> **Toda la gestión comercial en un solo lugar, adaptada al flujo de trabajo de Energica Solar.**

Kusdy debe aportar valor mediante:

- CRM diseñado específicamente para Energica Solar S.A.
- Centralización de clientes y actividades comerciales.
- Historial completo por cliente.
- Seguimiento de llamadas.
- Seguimiento de citas.
- Seguimiento de cotizaciones.
- Seguimiento de oportunidades comerciales.
- Recordatorios y notificaciones.
- Dashboard comercial.
- Reportes.
- Acceso desde distintos dispositivos.
- Menor dependencia de Excel.
- Menor dependencia de agendas físicas.
- Menor riesgo de perder clientes por falta de seguimiento.
- Ahorro de tiempo.

---

## 7. Segmentos y usuarios

### Cliente comprador

**Energica Solar S.A.**

Es la organización para la cual se desarrollará Kusdy.

### Usuarios finales

**Vendedores de Energica Solar S.A.**

Los vendedores utilizarán la aplicación para gestionar su actividad comercial diaria.

### Consideración importante

Kusdy **no está planteado actualmente como un SaaS multiempresa ni como un producto masivo**.

Es un **software a medida** para Energica Solar S.A.

Por lo tanto, los agentes no deben diseñar funcionalidades de multiempresa, marketplace, planes SaaS o administración de múltiples compañías salvo que el alcance cambie explícitamente.

---

## 8. Funcionalidades contempladas

Las siguientes funciones están contempladas dentro del producto:

### Gestión de usuarios

- Múltiples usuarios.
- Los usuarios previstos son vendedores.
- Actualmente **no se ha planteado un sistema complejo de roles** porque los usuarios tendrán funciones similares.
- **Decisión confirmada (2026-10-05):** cada vendedor ve **solo sus propios clientes** (y las actividades y cotizaciones de ellos).
- **Decisión confirmada (2026-10-05):** en la primera etapa **solo Freddy usará Kusdy**. Si se extiende al resto de la empresa, el administrador podrá reasignar clientes entre vendedores (pendiente para esa etapa).
- **Requerimiento de Freddy (2026-10-22):** aunque hoy solo él usa Kusdy, la base de datos debe soportar **varios vendedores organizados por sucursal** sin rediseñarse después, porque se harán reportes por grupo de ventas (sucursal).
- **Decisión confirmada (Freddy, 2026-10-22): estructura de roles de Energica**, de menor a mayor: **Instalador → Vendedor → Jefe de sucursal → Supervisor → Gerente general**. **Grupo de ventas = sucursal**: cada sucursal tiene un solo grupo (sus vendedores y su jefe). Energica tiene **5 sucursales** y **un supervisor** que revisa las 5. Freddy es **jefe de sucursal**; su sucursal tiene 10 vendedores más él. **Cada usuario tiene como atributo la sucursal a la que pertenece.** Los **instaladores no usan la app en la primera versión**, pero quedan contemplados en la base de datos. **Crear usuarios** lo pueden hacer el jefe de sucursal, el supervisor o el gerente general, y **las pantallas disponibles dependen del rol**.
- **Propuesta (2026-10-22):** visibilidad por rol: el instalador ve sus instalaciones asignadas; el vendedor, lo suyo; el jefe de sucursal, lo suyo y lo de su sucursal (y administra los usuarios de ella); el supervisor, las sucursales que supervisa (y administra usuarios de ellas); el gerente general, todo. Nadie crea ni edita a alguien de su mismo nivel o superior. Son puestos fijos, no un sistema de permisos configurable. Detalle y dudas en `kusdy/retro-fredy-2026-10.md`.

> No agregar jerarquías, permisos avanzados o RBAC complejo sin validación.

### Gestión de clientes

Debe existir una forma de:

- Registrar clientes.
- Consultar clientes.
- Actualizar clientes.
- Mantener información de contacto.
- Consultar el historial del cliente.
- Relacionar actividades comerciales con un cliente.
- **Filtrar y ordenar la lista de clientes (requerimiento de Freddy, 2026-10-22).** Lo más importante para él: ver los clientes que **no contestaron** y **ordenar por fechas**. Los filtros se presentan como **listado** (hoja con opciones en filas), no como burbujas/chips.

### Seguimiento comercial

Kusdy debe apoyar el seguimiento de:

- Llamadas.
- Citas.
- Visitas.
- Cotizaciones.
- Actividades pendientes.
- Oportunidades comerciales.

### Historial de clientes

Cada cliente debería contar con un historial que permita visualizar las actividades realizadas a lo largo del tiempo.

Ejemplos:

- Llamadas.
- Citas.
- Visitas.
- Cotizaciones.
- Notas.
- Seguimientos.

**Requerimiento de Freddy (2026-10-22):** los **comentarios** de cada cliente se muestran en una **tarjeta aparte** en la misma pantalla del historial, ordenados por fecha, con el **último comentario siempre visible**. El historial muestra los eventos y la tarjeta los comentarios.

### Registro del resultado de una llamada

**Requerimiento de Freddy (2026-10-22):** al tocar **Hecho** después de una llamada, la pantalla cambia según lo que pasó. Ejemplos dados por Freddy: si **no contestó**, ofrecer reagendar para más tarde u otro día; si **contestó y no le interesa**, solo dejar un comentario. La lista completa de resultados es una propuesta por validar (ver `kusdy/retro-fredy-2026-10.md`).

### Ventas

**Requerimiento de Freddy (2026-10-22):** las ventas se registran en Kusdy y guardan, como mínimo: **cliente, vendedor, información básica de la venta (productos, fecha, monto) y método de pago**.

**Reglas de precio (Freddy, 2026-10-22):**

- Cada producto tiene un **precio de lista**, casi siempre fijo e igual en las 5 sucursales.
- Cada 1 o 2 meses el **gerente general** fija un precio **"hasta en"** por producto: el mínimo del periodo (ej. lista 4,900, "hasta en" 4,200).
- Vender **por debajo del "hasta en"** es excepcional y requiere **autorización del jefe de sucursal**, pedida **siempre antes de la venta** y válida solo para esa venta.
- **Solo el jefe de sucursal autoriza** (el supervisor es un puesto nuevo y no lo hace en la práctica). **El jefe no necesita autorización** para sus propias ventas.
- Por confirmar: si dentro del rango (lista a "hasta en") el vendedor vende sin pedir nada en la app.

**Decisión de Chris (2026-10-22):** los cambios al catálogo de productos (sobre todo de precio, que son excepcionales y aplican a las 5 sucursales) quedan registrados en una **bitácora** con quién, cuándo, valor anterior y nuevo.

### Productos y métodos de pago

**Requerimiento de Freddy (2026-10-22):** existe un **catálogo de productos** (los datos reales los proporcionará Chris) y un catálogo de **métodos de pago**. No incluye control de inventario.

### Notificaciones y recordatorios

Se contempla incluir:

- Recordatorios de actividades pendientes.
- Alertas de seguimientos.
- Avisos de llamadas o citas próximas.

La implementación exacta todavía debe definirse.

### Dashboard

Se contempla un dashboard con información relevante para el vendedor.

Posibles categorías que el dashboard puede mostrar, siempre sujetas a validación:

- Seguimientos pendientes.
- Próximas citas.
- Actividades del día.
- Clientes recientes.
- Cotizaciones.
- Indicadores comerciales.

### Reportes

Se contempla la generación o visualización de reportes comerciales.

**Requerimiento de Freddy (2026-10-22):**

- **Reporte mensual** según las ventas de un **grupo de vendedores** (= una sucursal), y consolidado de las 5 sucursales para supervisor y gerente general.
- **Reporte trimestral** que se arma a partir de tres reportes mensuales.
- Freddy mencionó "etc.": puede haber más periodos (semestral, anual). El contenido exacto de cada reporte todavía debe definirse.

---

## 9. Alcance funcional mínimo inferido del contexto

Este apartado resume el núcleo funcional que todos los agentes deberían considerar al trabajar sobre Kusdy.

1. Autenticación de usuarios.
2. Gestión de usuarios vendedores.
3. Gestión de clientes.
4. Registro de datos de contacto.
5. Historial del cliente.
6. Registro de llamadas.
7. Registro de citas.
8. Registro de visitas.
9. Registro de cotizaciones.
10. Seguimiento de actividades comerciales.
11. Notificaciones o recordatorios.
12. Dashboard.
13. Reportes.
14. Acceso desde diferentes dispositivos.
15. Persistencia centralizada de la información.
16. Registro de ventas con productos y método de pago.
17. Catálogo de productos y de métodos de pago.
18. Filtros y orden en la lista de clientes.

---

## 10. Historias de usuario funcionales base

> **Nota:** estas historias consolidan las necesidades confirmadas del proyecto. Deben servir como contexto funcional y pueden convertirse posteriormente en backlog formal con criterios de aceptación detallados.

### HU-01 — Iniciar sesión

**Como** vendedor,  
**quiero** iniciar sesión en Kusdy,  
**para** acceder de forma segura a la información comercial.

---

### HU-02 — Registrar cliente

**Como** vendedor,  
**quiero** registrar los datos de un cliente,  
**para** mantener su información centralizada y disponible.

---

### HU-03 — Consultar clientes

**Como** vendedor,  
**quiero** buscar y consultar clientes,  
**para** acceder rápidamente a su información sin revisar archivos o agendas.

---

### HU-04 — Actualizar cliente

**Como** vendedor,  
**quiero** actualizar la información de un cliente,  
**para** mantener sus datos vigentes.

---

### HU-05 — Consultar historial

**Como** vendedor,  
**quiero** consultar el historial de un cliente,  
**para** recordar llamadas, citas, visitas, cotizaciones y seguimientos realizados.

---

### HU-06 — Registrar actividad

**Como** vendedor,  
**quiero** registrar actividades comerciales asociadas a un cliente,  
**para** mantener evidencia de cada interacción.

---

### HU-07 — Programar seguimiento

**Como** vendedor,  
**quiero** programar un seguimiento futuro,  
**para** recordar cuándo debo volver a contactar al cliente.

---

### HU-08 — Recibir recordatorios

**Como** vendedor,  
**quiero** recibir recordatorios de actividades pendientes,  
**para** reducir el riesgo de olvidar llamadas, citas o seguimientos.

---

### HU-09 — Gestionar cotizaciones

**Como** vendedor,  
**quiero** registrar y consultar cotizaciones asociadas a clientes,  
**para** llevar un mejor control del proceso comercial.

---

### HU-10 — Consultar dashboard

**Como** vendedor,  
**quiero** ver un dashboard con información relevante,  
**para** identificar rápidamente mis actividades y prioridades.

---

### HU-11 — Consultar reportes

**Como** vendedor,  
**quiero** consultar reportes comerciales,  
**para** comprender mejor mi actividad y seguimiento de clientes.

---

### HU-12 — Trabajar fuera de la oficina

**Como** vendedor,  
**quiero** consultar y registrar información desde distintos dispositivos,  
**para** mantener actualizado el sistema incluso cuando no estoy en la oficina.

---

### HU-13 — Filtrar y ordenar clientes

**Como** vendedor,  
**quiero** filtrar mis clientes (por ejemplo, los que no contestaron) y ordenarlos por fecha,  
**para** saber rápidamente a quién debo volver a llamar.

---

### HU-14 — Registrar el resultado de una llamada

**Como** vendedor,  
**quiero** indicar qué pasó en la llamada y que la app me ofrezca el siguiente paso adecuado (reagendar, comentar, agendar visita, registrar venta),  
**para** no dejar ningún cliente sin seguimiento.

---

### HU-15 — Registrar una venta

**Como** vendedor,  
**quiero** registrar una venta con el cliente, los productos, el monto y el método de pago,  
**para** llevar control de lo vendido y alimentar los reportes.

---

### HU-16 — Consultar reportes de ventas por sucursal

**Como** jefe de sucursal (o supervisor / gerente general),  
**quiero** ver reportes mensuales y trimestrales de las ventas de una sucursal (grupo de vendedores),  
**para** evaluar el desempeño comercial de las sucursales a mi cargo.

---

### HU-17 — Administrar usuarios según mi rol

**Como** jefe de sucursal, supervisor o gerente general,  
**quiero** crear, editar y desactivar las cuentas de las personas a mi cargo,  
**para** que cada empleado nuevo pueda usar Kusdy con los permisos de su puesto.

---

### HU-18 — Solicitar y autorizar un descuento

**Como** vendedor,  
**quiero** pedir a mi jefe de sucursal, antes de vender, autorización para dejar un producto por debajo del precio "hasta en" del periodo,  
**para** cerrar la venta sin cambiar el precio del catálogo.

**Como** jefe de sucursal,  
**quiero** aprobar o rechazar esas solicitudes desde la app,  
**para** controlar los descuentos de mi sucursal.

> Caso de uso contado por Freddy (2026-10-22). El flujo exacto es propuesta pendiente de su visto bueno.

---

## 11. Business Model Canvas

### 1. Segmentos del cliente

- Energica Solar S.A. como cliente principal.
- Equipo de vendedores como usuarios finales.
- Personal comercial encargado de clientes y oportunidades.
- Usuarios que actualmente dependen de Excel y agendas.

### 2. Propuesta de valor

- CRM a medida.
- Centralización de información.
- Historial del cliente.
- Seguimiento comercial.
- Recordatorios y notificaciones.
- Dashboard.
- Reportes.
- Acceso desde diferentes dispositivos.
- Menos trabajo duplicado.
- Menos olvidos.
- Más tiempo disponible para vender.

### 3. Relaciones con el cliente

- Atención directa y personalizada.
- Comunicación durante el desarrollo.
- Onboarding inicial.
- Tutoriales integrados.
- Capacitación.
- Acompañamiento durante la implementación.
- Soporte.
- Retroalimentación continua.

### 4. Canales

- Venta directa a Energica Solar S.A.
- Reuniones.
- Presentaciones.
- Demostraciones.
- Comunicación directa.
- Implementación del sistema.
- Capacitación presencial o virtual.
- Soporte posterior.

### 5. Actividades clave

- Levantamiento de requerimientos.
- Análisis.
- Diseño de UX/UI.
- Desarrollo.
- Backend.
- Base de datos.
- Gestión de clientes.
- Historial.
- Dashboard.
- Reportes.
- Notificaciones.
- Pruebas.
- Corrección de errores.
- Implementación.
- Capacitación.
- Mantenimiento.

### 6. Recursos clave

- Equipo de desarrollo.
- Conocimientos técnicos.
- Flutter.
- Supabase (backend como servicio).
- PostgreSQL (incluido en Supabase).
- Equipos de cómputo.
- Internet.
- Herramientas de desarrollo.
- Información de Energica Solar.
- Retroalimentación de usuarios.

### 7. Socios clave

- Supabase (base de datos, autenticación, API, almacenamiento).
- Google Play / Apple como tiendas de distribución.
- Firebase Cloud Messaging para notificaciones push si se incorporan.
- Energica Solar S.A. como colaborador para validación y pruebas.
- Servicios externos de correo o notificaciones si se incorporan.

### 8. Estructura de costos

#### Costos iniciales

- Análisis.
- Diseño.
- Desarrollo frontend.
- Desarrollo backend.
- Base de datos.
- Pruebas.
- Implementación.
- Capacitación.

#### Costos operativos

- Supabase plan Pro en producción (incluye base de datos, autenticación, SSL y backups diarios).
- Cuentas de desarrollador de tiendas (Google Play pago único; Apple anual si se publica en iOS).
- Mantenimiento.
- Soporte.
- Actualizaciones.

Ya no se requieren hosting/VPS, dominio ni certificado SSL propios: Supabase los cubre. Ver detalle en `kusdy/costos.md`.

### 9. Fuentes de ingresos

- Pago único por el desarrollo de Kusdy.
- Licencia de uso.
- Implementación.
- Configuración inicial.
- Entrega del sistema según requerimientos acordados.

---

## 12. Modelo comercial

Kusdy se plantea actualmente bajo un modelo de:

**Pago único + licencia de uso**

Esto significa que:

- No se ha definido un modelo de suscripción mensual.
- No se han definido planes.
- No se ha definido cobro por usuario.
- No se ha definido modalidad freemium.
- No se ha planteado la venta a otras empresas.

No implementar lógica comercial SaaS salvo cambio explícito del alcance.

---

## 13. Tecnología contemplada

### Frontend / aplicación

**Flutter**

Flutter es la tecnología prevista para la aplicación.

El objetivo es aprovechar una base de código común y facilitar el acceso desde distintos dispositivos.

### Base de datos y backend — **Decisión confirmada (2026-10-05)**

**Supabase** (PostgreSQL administrado) reemplaza a MySQL y al backend propio.

```text
Flutter (supabase_flutter)
   |
   | HTTPS (API de Supabase + Auth)
   v
Supabase: Auth · API REST/PostgREST · Edge Functions · Storage
   |
   v
PostgreSQL (con Row Level Security)
```

La aplicación **nunca usa credenciales de administrador** de la base de datos: solo la clave pública, y la seguridad se garantiza con **Row Level Security (RLS)** activada en todas las tablas.

Supabase (vía RLS, funciones SQL y Edge Functions) concentra:

- Autenticación.
- Reglas de negocio.
- Validaciones.
- Acceso a datos.
- Seguridad.
- Generación de reportes.
- Lógica de notificaciones.
- Exposición de endpoints.

### Hosting

Lo provee Supabase. No se requiere servidor propio.

---

## 14. Arquitectura conceptual

La arquitectura objetivo debe mantener separación de responsabilidades.

### Capa de presentación

Responsable de:

- Interfaces.
- Formularios.
- Navegación.
- Dashboard.
- Visualización de clientes.
- Visualización de historial.
- Reportes.
- Alertas.

Tecnología prevista:

- Flutter.

### Capa de aplicación / negocio

Responsable de:

- Casos de uso.
- Validaciones.
- Seguimientos.
- Reglas de clientes.
- Reglas de cotizaciones.
- Gestión de actividades.
- Generación de indicadores.

Tecnología:

- Supabase: funciones SQL (RPC), Row Level Security y Edge Functions (TypeScript) donde haga falta.

### Capa de datos

Responsable de:

- Persistencia.
- Consultas.
- Relaciones entre entidades.
- Integridad de datos.

Tecnología confirmada:

- PostgreSQL (Supabase).

---

## 15. Entidades conceptuales iniciales

Estas entidades se derivan del contexto funcional y sirven como punto de partida para análisis de dominio.

No deben considerarse todavía un modelo físico definitivo.

> **Actualización 2026-10-22:** tras la retroalimentación de Freddy se agregan Sucursal, Comentario, Producto, Venta, Pago y Método de pago. El modelo conceptual detallado (propuesta) está en `kusdy/plan-tecnico-v1.md`, Parte 4.

### Usuario

Representa a un vendedor que utiliza Kusdy.

Posibles atributos:

- id
- nombre
- correo
- contraseña/hash (la gestiona Supabase Auth)
- rol (confirmado: instalador, vendedor, jefe de sucursal, supervisor, gerente general)
- sucursal a la que pertenece (vacía para supervisor y gerente general)
- estado (activo/inactivo; nunca se borra)
- fecha de creación

### Sucursal (= grupo de ventas)

Sucursal de Energica (hoy 5). Sus vendedores y su jefe forman un grupo de ventas, que es la unidad de los reportes mensuales y trimestrales.

Posibles atributos: id, nombre, ciudad, jefe de sucursal, supervisor, estado.

### Cliente

Representa un cliente o prospecto.

Posibles atributos:

- id
- nombre
- teléfono
- correo
- dirección o ubicación
- tipo de cliente
- notas
- estado
- fecha de registro

### Actividad

Representa una interacción o tarea comercial.

Posibles tipos:

- llamada
- cita
- visita
- seguimiento
- nota

Posibles atributos:

- id
- cliente
- usuario
- tipo
- fecha
- descripción
- estado

### Cotización

Representa una cotización comercial asociada a un cliente.

Posibles atributos:

- id
- cliente
- usuario
- fecha
- descripción
- monto
- estado

### Comentario

Nota escrita por un usuario sobre un cliente, con fecha y autor. Puede salir de una llamada u otra actividad, o escribirse sola. Se muestra en la tarjeta de comentarios del cliente.

Posibles atributos: id, cliente, autor, actividad (opcional), texto, fecha.

### Producto

Producto que vende Energica Solar (calentadores, paneles, etc.). Los datos reales los proporcionará Chris.

Posibles atributos (por validar): id, nombre, categoría, descripción/capacidad, precio de referencia, código, estado.

### Venta

Venta concretada a un cliente.

Posibles atributos: id, cliente, vendedor, sucursal del vendedor al momento de la venta, fecha, productos vendidos (cantidad y precio de ese momento), total, moneda, estado (registrada/anulada), cotización de origen (opcional), comentario.

### Pago y método de pago

Cada venta tiene uno o más pagos; cada pago tiene un método (efectivo, transferencia, tarjeta, financiamiento… por confirmar) y un monto.

### Recordatorio

Representa una actividad que debe notificarse al usuario.

Posibles atributos:

- id
- actividad
- usuario
- fecha y hora
- estado

### Historial

El historial puede construirse a partir de actividades, cotizaciones y otras interacciones asociadas al cliente.

No necesariamente necesita existir como tabla independiente.

---

## 16. Principios de UX

Kusdy debe priorizar:

- Simplicidad.
- Claridad.
- Pocos pasos para registrar información.
- Navegación intuitiva.
- Información comercial visible rápidamente.
- Formularios comprensibles.
- Compatibilidad con usuarios que vienen de Excel y agenda física.
- Uso cómodo desde dispositivos móviles.
- Lectura clara para usuarios de distintas edades.
- Evitar interfaces sobrecargadas.

El sistema debe reducir fricción, no trasladar la complejidad de Excel a una interfaz nueva.

---

## 17. Onboarding y capacitación

El proyecto contempla:

- Onboarding inicial.
- Tutoriales dentro del sistema.
- Capacitación a usuarios.
- Acompañamiento durante la implementación.

El onboarding debe ayudar al vendedor a comprender, como mínimo:

1. Cómo iniciar sesión.
2. Cómo registrar un cliente.
3. Cómo consultar un cliente.
4. Cómo registrar una actividad.
5. Cómo programar un seguimiento.
6. Cómo revisar pendientes.
7. Cómo consultar el historial.
8. Cómo utilizar el dashboard.

---

## 18. Reglas y restricciones conocidas

1. Kusdy es para Energica Solar S.A.
2. Los usuarios previstos son vendedores.
3. No se contempla actualmente un sistema complejo de roles.
4. El modelo comercial es de pago único/licencia.
5. Flutter está contemplado para la aplicación.
6. Supabase (PostgreSQL) es la base de datos y backend.
7. Toda tabla debe tener Row Level Security activa; la app nunca usa credenciales de administrador.
8. La información comercial debe centralizarse.
9. Debe existir acceso desde distintos dispositivos.
10. Debe reducirse la dependencia de Excel y agenda física.
11. Debe existir historial por cliente.
12. Deben existir recordatorios o notificaciones.
13. Se contemplan reportes.
14. Se contempla un dashboard.
15. La aplicación debe ser fácil de usar.
16. La base de datos debe soportar los 5 roles y las sucursales desde el inicio, aunque al principio solo Freddy use Kusdy (2026-10-22).
17. Las ventas guardan referencias a cliente, vendedor, productos y método de pago (no textos sueltos), y el precio de cada producto tal como se vendió.
18. Las ventas no se borran: se anulan, para no alterar reportes sin rastro.

---

## 19. No objetivos actuales

Salvo que el alcance cambie, **no forman parte del objetivo actual**:

- Convertir Kusdy en un SaaS multiempresa.
- Crear planes de suscripción.
- Cobro mensual por usuario.
- Marketplace.
- Gestión de múltiples compañías.
- Sistema complejo de roles.
- ERP completo.
- Gestión contable.
- Gestión de inventario empresarial completa. (El catálogo de productos sí está contemplado; las existencias no.)
- Comercio electrónico.
- Aplicación pública para clientes finales.

Un agente no debe ampliar el sistema hacia estas áreas sin requerimiento explícito.

---

## 20. Pendientes por definir

Los siguientes puntos todavía requieren decisión explícita:

### Tecnología

- ~~Framework del backend, ORM y hosting~~ → resuelto: Supabase.
- Estrategia de despliegue de la app (tiendas, APK directo).
- Gestión de archivos.
- Proveedor de correo.
- Tecnología de notificaciones.
- Estrategia de backups (Supabase Pro incluye backups diarios; definir si basta).

### Funcionalidad

- Campos definitivos de cliente.
- Estados del cliente.
- ~~Filtros y resultados de llamada~~ → resuelto (Freddy, 2026-10-22): "no contestaron" = última llamada; ordenar por próxima llamada, último contacto o fecha de registro (desplegable); filtros por mes de registro (prioritario), producto y ciudad; resultados incluyen "número equivocado" y "no volver a llamar"; tras 3 llamadas sin respuesta se muestra el conteo; "no le interesa" = perdido por defecto con opción de volver a intentar; nota fija opcional por cliente además de los comentarios.
- ~~Ventas~~ → resuelto: métodos de pago **crédito, efectivo, tarjeta, Visacuotas**; moneda **quetzales (GTQ)**; número de venta **autoasignado** (digitalizar facturas físicas queda para muy a futuro); la **instalación se cobra aparte**.
- Resuelto también: el **crédito** se paga en cuotas directamente a Energica (hay que llevar el saldo); el número de venta es **por sucursal**; la instalación **no tiene precio fijo** (depende de estructura, nivelación, etc.).
- Datos reales de productos (los proporciona Chris).
- ~~Quién edita productos y métodos de pago; precios por sucursal~~ → resuelto (Freddy, 2026-10-22): jefe de sucursal, supervisor y gerente general editan productos; los métodos de pago casi no cambian (solo se agrega uno en casos muy específicos); **los precios son iguales en las 5 sucursales**.
- ~~Reportes~~ → resuelto (Freddy, 2026-10-22): cada vendedor ve su propio reporte; hay **metas mensuales por grupo (sucursal)** que fija el gerente general; los reportes **se cierran a fin de mes**; se exportan a **PDF**; reportes de llamadas/visitas no por ahora.
- Resuelto (2026-10-22): **el jefe de sucursal cierra el mes**; el reporte cuenta **lo cobrado** en el mes; **el vendedor da seguimiento al cobro de cuotas**; el precio de la **instalación requiere visto bueno del jefe**; el "hasta en" es igual en las 5 sucursales y lo carga el gerente general; la autorización de descuento no vence; la **Agenda es solo por día** e incluye las fechas de cobro.
- Pendiente: contenido exacto del reporte mensual.
- Estados de cotización.
- Flujo exacto de oportunidad de venta.
- Indicadores del dashboard.
- ~~Reportes específicos~~ → parcialmente definido: mensual y trimestral por sucursal y consolidado (contenido pendiente).
- Tipo de notificaciones.
- Frecuencia de recordatorios.
- Si existirán notas internas.
- Si se podrán adjuntar documentos.
- Si habrá exportación a PDF o Excel.
- Si habrá recuperación de contraseña.
- Si habrá sincronización con calendarios externos.

### Seguridad

- Política de contraseñas.
- Duración de sesión.
- Recuperación de contraseña.
- Auditoría de acciones.
- Cifrado de datos sensibles.
- Política de backups.
- Gestión de sesiones.

### Negocio

- Precio de la licencia.
- Alcance del soporte posterior.
- Garantía.
- Mantenimiento posterior.
- Quién paga el costo mensual de Supabase (Energica o incluido en mantenimiento).

---

## 21. Criterios generales de desarrollo para agentes de IA

Todo agente que trabaje con Kusdy debería seguir estas reglas:

### 21.1 No inventar requerimientos

Si una funcionalidad no aparece en este contexto o en una historia/requerimiento nuevo, debe tratarse como pendiente.

### 21.2 Separar decisión de propuesta

Cuando un agente sugiera una tecnología o funcionalidad nueva debe marcarla como:

- **Propuesta**, o
- **Decisión confirmada**.

No mezclar ambas.

### 21.3 Mantener el alcance

Kusdy es un CRM interno a medida.

No convertirlo automáticamente en:

- ERP.
- SaaS.
- Sistema de inventario.
- Ecommerce.
- Suite empresarial.

### 21.4 Priorizar el problema real

Toda funcionalidad debe responder, directa o indirectamente, a uno de estos objetivos:

- mejorar seguimiento;
- centralizar información;
- reducir olvidos;
- ahorrar tiempo;
- facilitar consulta;
- mantener historial;
- ayudar a vender.

### 21.5 Evitar sobreingeniería

El sistema debe ser mantenible y adecuado para una empresa concreta.

No introducir microservicios, arquitectura distribuida, colas, Kubernetes u otras tecnologías complejas sin una necesidad real.

### 21.6 Mantener trazabilidad

Toda funcionalidad debería poder relacionarse con:

- una necesidad del usuario;
- una historia de usuario;
- una regla de negocio;
- un requisito funcional.

---

## 22. Priorización inicial sugerida

### Prioridad alta

- Autenticación.
- Gestión de usuarios.
- Gestión de clientes.
- Historial.
- Registro de actividades.
- Seguimientos.
- Recordatorios.
- Dashboard básico.

### Prioridad media

- Ventas y catálogo de productos (sube de prioridad tras la retroalimentación de Freddy).
- Cotizaciones.
- Reportes de ventas mensual y trimestral.
- Filtros de clientes (al menos "no contestaron" y orden por fecha entran con la lista de clientes).
- Mejoras de dashboard.
- Onboarding.

### Prioridad posterior

- Integraciones externas.
- Exportaciones.
- Automatizaciones avanzadas.
- Integración con calendario.
- Integración con correo.

La priorización es una guía y puede modificarse.

---

## 23. Flujo comercial conceptual

Un flujo de referencia podría ser:

```text
Cliente / Prospecto
        |
        v
Registro en Kusdy
        |
        v
Primer contacto
        |
        v
Llamada / Visita / Cita
        |
        v
Cotización
        |
        v
Seguimiento
        |
        +--------------------+
        |                    |
        v                    v
Venta concretada      Seguimiento futuro
```

Este flujo es conceptual y debe validarse con Energica Solar antes de convertirse en una máquina de estados rígida.

---

## 24. Métricas potenciales del dashboard

Estas métricas son candidatas, no decisiones finales:

- Clientes registrados.
- Clientes contactados.
- Seguimientos pendientes.
- Seguimientos vencidos.
- Citas próximas.
- Llamadas pendientes.
- Cotizaciones registradas.
- Cotizaciones pendientes.
- Actividades realizadas.
- Actividades por periodo.

Los agentes deben validar cuáles serán realmente utilizadas.

---

## 25. Definición de éxito

Kusdy será útil si logra que el equipo comercial pueda:

- trabajar con una única fuente principal de información;
- saber qué cliente necesita seguimiento;
- consultar antecedentes rápidamente;
- registrar actividades sin duplicar trabajo;
- reducir olvidos;
- trabajar desde fuera de la oficina;
- gastar menos tiempo en tareas administrativas;
- mantener mejor continuidad en el proceso de venta.

---

## 26. Resumen corto para agentes

Si un agente necesita entender Kusdy rápidamente, debe partir de esto:

> **Kusdy es un CRM a medida para Energica Solar S.A., orientado a vendedores.** Registra llamadas con su resultado, comentarios por cliente, ventas con productos y método de pago, y genera reportes mensuales y trimestrales por sucursal (grupo de vendedores). Hoy solo lo usa Freddy (jefe de sucursal), pero el modelo de datos soporta desde el inicio los 5 puestos de la empresa (instalador, vendedor, jefe de sucursal, supervisor, gerente general) y sus 5 sucursales.
>
> Surge porque el seguimiento comercial se realiza actualmente con Excel y agenda física, lo que genera duplicación, olvidos y dificultad para mantener información sincronizada. Kusdy debe centralizar clientes, historial, llamadas, citas, visitas, cotizaciones y seguimientos, incluir recordatorios, dashboard y reportes, y ser accesible desde distintos dispositivos. Se usa Flutter para la aplicación y Supabase (PostgreSQL) como base de datos y backend. No es un SaaS multiempresa; los roles son los 5 puestos fijos de la empresa, sin permisos configurables. El modelo comercial es un pago único/licencia. La prioridad del producto es simplicidad, seguimiento efectivo y ahorro de tiempo.

---

## 27. Regla final de contexto

Cuando exista contradicción entre este archivo y un requerimiento nuevo confirmado por el equipo:

1. prevalece el requerimiento nuevo;
2. debe actualizarse este archivo;
3. los agentes deben evitar mantener dos versiones contradictorias de la misma decisión.

Este documento debe evolucionar junto con Kusdy.
