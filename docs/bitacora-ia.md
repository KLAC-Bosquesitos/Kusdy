# Bitácora de uso de IA

Cada uso de IA que termina en el repo se registra aquí (el más reciente arriba).
El objetivo no es justificar el uso, sino demostrar **criterio**:
qué especificaste, qué revisaste y qué rechazaste.

| Campo | Qué escribir |
|---|---|
| Fecha / autor | `2026-10-15 · @usuario` |
| Herramienta | Claude, Copilot, ChatGPT… |
| Especificación | Qué pediste y con qué restricciones (pegar el prompt o resumirlo) |
| Resultado | Qué devolvió, en una frase |
| Aceptado | Qué quedó en el código y por qué |
| Rechazado / corregido | Qué cambiaste y por qué. **Esta es la columna más importante.** |
| Verificación | Cómo comprobaste que funciona (pruebas, dispositivo) |
| Commit / PR | Enlace |

---
## 2026-11-04 · @Andrea2507 / @Kennethram15 — Sprint 3, PR 2.2 (Pantalla «¿Qué pasó?» y Mover)

- **Herramienta:** ChatGPT para analizar las instrucciones del Sprint 3, orientar la integración de los archivos, verificar los resultados de las pruebas y apoyar la documentación del trabajo realizado.

- **Especificación:** Incorporar las funcionalidades del PR 2.2, correspondientes a la pantalla dinámica «¿Qué pasó?», el reagendamiento de actividades y la presentación de llamadas pendientes y vencidas. Respetar la arquitectura por features, los contratos de repositorios, Riverpod, la paleta KusdyColors y las funcionalidades existentes de Hoy y Agenda.

- **Resultado:** Se incorporaron en la rama `feat/que-paso` las pantallas y componentes relacionados con el registro de resultados de llamadas, los atajos para reagendar actividades, las tarjetas compartidas de Hoy y Agenda y las pruebas de lógica y widgets correspondientes.

- **Aceptado:** Se mantuvo la separación entre presentación, lógica y acceso a datos. Se reutilizaron los providers y contratos existentes, evitando consultas directas a Supabase desde las pantallas. Se conservaron las funcionalidades anteriores de Hoy y Agenda, incluyendo los estados de consulta y la cancelación de actividades.

- **Rechazado / corregido:** Se evitó modificar archivos ajenos al PR, agregar dependencias innecesarias y sobrescribir los avances de otros integrantes. El archivo ZIP original se mantuvo fuera del repositorio para no incluirlo accidentalmente en el commit. Se habilitó el modo de desarrollador de Windows para permitir la preparación de los plugins requeridos por Flutter.

- **Verificación:** Se ejecutó `dart format --output=none --set-exit-if-changed lib test`, sin modificaciones. `flutter analyze` terminó sin observaciones y `flutter test` finalizó con 73 pruebas aprobadas. Se confirmó que `pubspec.lock` no presentó modificaciones. La comprobación del flujo completo con Supabase y las pruebas manuales en un dispositivo permanecen pendientes.

- **Commit / PR:** Issue #34. PR #38.

## 2026-11-04 · @Kennethram15 / @Andrea2507 — Sprint 3, PR 2.1 (Llamadas y Supabase)

- **Herramienta:** ChatGPT para analizar las instrucciones del Sprint 3, revisar la integración de archivos, orientar la ejecución de pruebas y apoyar la documentación técnica.

- **Especificación:** Integrar los archivos proporcionados para el PR 2.1, relacionados con la migración 5 y el repositorio de actividades en Supabase. Respetar la arquitectura por features, los contratos existentes, Riverpod, las políticas RLS y las migraciones anteriores. Evitar modificaciones ajenas a la tarea y conservar los avances integrados por los demás integrantes.

- **Resultado:** Se incorporaron en la rama `feat/registrar-llamada` los archivos de la migración `registrar_resultado_llamada`, su prueba SQL, el repositorio de actividades de Supabase, la actualización del provider, las pruebas de datos y los cambios del flujo de integración continua. También se completó el ADR 0003, que explica por qué se utiliza una función transaccional en PostgreSQL.

- **Aceptado:** Se conservaron los contratos y la estructura existente del proyecto. Se mantuvo el uso de una función de PostgreSQL para registrar el resultado de las llamadas en una transacción, respetando los permisos establecidos mediante RLS. No se modificaron las migraciones anteriores ni se agregaron dependencias innecesarias.

- **Rechazado / corregido:** Se evitó incluir el archivo ZIP original en el repositorio y modificar archivos ajenos a la tarea. No se instaló PostgreSQL únicamente para ejecutar la prueba SQL local, ya que el proyecto dispone de una comprobación automatizada mediante GitHub Actions. Se mantuvo pendiente la aplicación de la migración en `kusdy-dev` hasta su integración y autorización correspondiente.

- **Verificación:** Se ejecutó `dart format --output=none --set-exit-if-changed lib test`, con 0 archivos modificados. `flutter analyze` terminó sin observaciones y `flutter test` finalizó con 67 pruebas aprobadas. Se comprobó que `pubspec.lock` no presentó modificaciones. .La prueba SQL de la migración 5 se ejecutó correctamente en GitHub Actions utilizando PostgreSQL 17.

- **Commit / PR:** Issue #33. PR #39.

## 2026-11-01 · @Kennethram15 / @Andrea2507 — Lab S16, Parte B (CRUD de categorías)

- **Herramienta:** ChatGPT para el análisis del repositorio, la planificación de la integración y la revisión de instrucciones. [Agregar otra herramienta de IA utilizada, si corresponde.]

- **Especificación:** Revisar los archivos de la pareja 2 para integrar el CRUD de categorías de productos sin afectar las funcionalidades existentes. Mantener la arquitectura por features, Riverpod, los repositorios definidos, el tema KusdyColors y las pruebas de widget. Respetar la migración y los archivos de la pareja 1.

- **Resultado:** Se preparó la integración de CategoriasScreen, CategoriaFormScreen y categoriasProvider, con navegación desde Más, operaciones de creación, edición, archivado y eliminación, estados de consulta y ocho pruebas de widget.

- **Aceptado:** [Indicar los componentes que efectivamente quedaron integrados y por qué se conservaron.]

- **Rechazado / corregido:** Se evitó duplicar el repositorio de categorías y modificar las migraciones existentes. [Agregar las correcciones reales realizadas tras revisar código o pruebas.]

- **Verificación:** [Registrar resultados reales de dart format, flutter analyze y flutter test. Indicar si se probó en emulador y si se verificó la persistencia en Supabase.]

- **Commit / PR:** Issue #26 · [Agregar el enlace al PR correspondiente.]


## 2026-10-17 · @kennethram15 / @andrea2507 — Lab S14, Parte B (Inicio con 4 estados)

- **Herramienta:** Claude para la solución inicial y ChatGPT para la revisión técnica y orientación.

- **Especificación:** Implementar la pantalla "Clientes para hoy" (HU-10) con cuatro estados: cargando, error con Reintentar, vacío y datos. Reutilizar los componentes compartidos de la pantalla Clientes, utilizando Riverpod y un repositorio falso debido a que la base de datos todavía no está implementada.

- **Resultado:** Se incorporó la funcionalidad `features/hoy`, incluyendo modelos, repositorio falso, providers, pantalla y cuatro pruebas de widget. Se modificó `app.dart` para que la aplicación inicie en "Clientes para hoy".

- **Aceptado:** Se reutilizaron los widgets `EstadoCargando`, `EstadoError` y `EstadoVacio` para mantener consistencia con la pantalla Clientes. Se conservaron los datos simulados para probar la funcionalidad sin conectarse a una base de datos.

- **Rechazado / corregido:** Se descartó sobrescribir los archivos de documentación existentes al incorporar el ZIP. Se conservaron los avances de los demás integrantes y no se agregaron funcionalidades fuera del alcance del laboratorio.

- **Verificación:** Se probaron los estados cargando, error, vacío y datos en Chrome. Se comprobó el funcionamiento de Reintentar y la navegación a Clientes. Se ejecutaron `flutter analyze` y `flutter test`, con resultados satisfactorios.

- **Commit / PR:** Issue #15. Commit de implementación `8231ef7`. Pendiente agregar el enlace al Pull Request.

---


## 2026-10-15 · @chrisram21 — Lab S14, Parte B (Clientes con 4 estados)

- **Herramienta:** Claude.
- **Especificación:** pantalla de clientes (HU-03) con cargando, error con Reintentar, vacío con
  acción y datos, usando `AsyncValue.when`; repositorio que devuelve un `Future` con datos fijos y
  `Future.delayed` (la base de datos sigue en pausa); reintento automático de Riverpod 3 desactivado;
  prueba de widget del error con override. Arquitectura por features y colores de `KusdyColors`
  según `AGENTES.md`. Sin funcionalidades nuevas.
- **Resultado:** `features/clientes` (dominio, repositorio falso, providers, pantalla), widgets de
  estado en `core/widgets`, `app/theme.dart` y 4 pruebas de widget.
- **Aceptado:** Se dejo como estaba la parte del --dart-define para fingir estados mientras no hacemos la conexion a la base de datos y los colores
- **Rechazado / corregido:**
  - Se agregó `flutter_riverpod` pero no `riverpod_generator`: para un `FutureProvider` no hace falta
    generar código todavía.
- **Verificación:** `dart format`, `flutter analyze` (sin observaciones) y `flutter test` (4 pruebas en
  verde) con Flutter 3.44.5.
  Las 4 pruebas mostraron sus respectivos objetivos, la primera fue de carga normal sin ningun estado.
  La segunda fue una demora en la carga de datos y mostar una pantalla de carga
  La tercera fue una pantalla de error
  La cuarta fue en caso de que no hubiera datos que mostrar
- **Commit / PR:** <!-- enlace al PR de la pareja -->

---

## 2026-10-15 · @chrisram21 — Lab S14, Parte A (CI)

- **Herramienta:** Claude.
- **Especificación:** "Lee el PDF del Lab S14 y planifica cómo seguir con Kusdy". Después: preparar
  los archivos de CI a partir de inkash (`s14-06-ci`) con Flutter 3.44.5 y los usuarios del equipo,
  sin hacer commits (los hace el integrante tras revisar).
- **Resultado:** `ci.yml`, plantilla de PR, `CODEOWNERS`, plantilla de historia de usuario y esta bitácora.
- **Aceptado:** <!-- Chris: qué dejaste tal cual y por qué -->
- **Rechazado / corregido:**
  - Respecto a inkash: se agregó `working-directory: kusdy` porque la app vive en una subcarpeta;
    se quitó el paso de SQLite (Kusdy no usa sqflite); la ruta del APK se ajustó a `kusdy/build/...`.
  - <!-- Chris: lo que cambiaste tú al revisar -->
- **Verificación:** `dart format`, `flutter analyze` y `flutter test` locales con Flutter 3.44.5; check del PR en verde.
- **Commit / PR:** <!-- enlace al PR chore/ci -->


## 2026-10-29 · @chrisram21 — Lab S16, Parte A (Login)

- **Herramienta:** Claude.
- **Especificación:** Lee el archivo y reparte la actividad en dos partes para divinirnos en dos parejas como hemos venido haciendo, vamos a utilizar supabase y el ingeniero ya esta enterado de ello entonces continua.
- **Resultado:** `ci.yml`, plantilla de PR, `CODEOWNERS`, plantilla de historia de usuario y esta bitácora.
- **Aceptado:** Las migraciones de supabase para crear el login
- **Rechazado / corregido:**
  - Respecto a inkash: se agregó `working-directory: kusdy` porque la app vive en una subcarpeta;
    se quitó el paso de SQLite (Kusdy no usa sqflite); la ruta del APK se ajustó a `kusdy/build/...`.
- **Verificación:** `dart format`, `flutter analyze` y `flutter test` locales con Flutter 3.44.5; check del PR en verde.
- **Commit / PR:** <!-- enlace al PR chore/ci -->

## 2026-11-1 · @wishosz — Lab S16, Parte B (Migracion de categorías)

- **Herramienta:** Claude.
- **Especificación:** Implementar `CategoriasRepositorySupabase` sobre la tabla `categorias_producto` (migración 4) cumpliendo el contrato `CategoriasRepository` sin tocar las pantallas.
- **Resultado:** repositorio Supabase (listar con conteo de productos, crear, renombrar, archivar y
  eliminar), función `traducirErrorCategoria` y 4 pruebas unitarias de esa traducción.
- **Aceptado:** Contar las categorias en la misma consulta, validaciones para vacios y el definir al provider como unico punto de cambio.
- **Rechazado / corregido:** Una correción fue definir que cuando se desee eliminar una categoría indique la cantidad de productos con los que se encuentran en uso. Además decidí no se borrar `categorias_repository_memoria.dart` porque sigue sirviendo para pruebas y para trabajar sin red.
- **Verificación:** `flutter analyze` sin observaciones; `flutter test` en verde; prueba de migración (`supabase/pruebas/20_migracion_categorias.sql`) en verde en el job "Migraciones de la base" del CI. El CI encontró que la migración elegía el nombre de la categoría según el orden alfabético del servidor; se corrigió para que dé lo mismo en cualquier Postgres.
- **Commit / PR:** #28

## 2026-11-3 · @chrisram21 — Sprint 3 base comun

- **Herramienta:** Claude.
- **Especificación:** Crear la base dentro del repositorio para que ambas parejas puedan trabajar simultaneamente sin merge conflicts y poder crear las funcione que hagan falta.
- **Resultado:** correccion de repositorios falsos a los reales y correccion de contratos faltantes.
- **Aceptado:** Cambios dentro de los archivos de repositorios para que se unifiquen ciertas aspectos de la aplicacion y tambien dentro de los dominios.
- **Rechazado / corregido:** No hubo tantas correcciones ya que solo se trata de dejar de usar los repositorios falsos y usar los verdaderos ademas de plantar las bases.
- **Verificación:** `flutter analyze` sin observaciones; `flutter test` en verde.
- **Commit / PR:** #29

## 2026-11-3 · @wishosz — Clientes desde Supabase

- **Herramienta:** Claude.
- **Especificación:** Crear el repositorio y archivos correspondientes para traer los clientes desde la base de datos de supabase. Estos se mostratan en la pantalla de Clientes, mostrados como los datos de ejemplo.
- **Resultado:** La pantalla de clientes trae los clientes reales guardados en la base de Supabase.
- **Aceptado:** Creación de 3 archivos nuevos para gestionar el repositorio de clientes y comentarios. Además de editar el provider de estos para que si tome los repositorios de Supabase.
- **Rechazado / corregido:** Fue bastante lineal, como la pantalla de los usuarios ya existia entonces la incorporación de los repositorios desde Supabase no causó mayor problema.
- **Verificación:** `flutter analyze` sin observaciones o alertas; En `flutter test` pasaron todas las pruebas. Además de una prueba manual donde se ve que los clientes son los guardados en la base de Supabase.
- **Commit / PR:** #37

## 2026-11-3 · @chrisram21 Co-authored-by: WishoSz — Formulario y detalle del cliente

- **Herramienta:** Claude.
- **Especificación:** El apartado del  CRUD para los clientes que vengan desde supabase, vamos a hacer un formulario unico para crear y editar clietnes.
- **Resultado:** Varias pantllas nuevas para mostrar los datos de los clientes y poder manejarlos
- **Aceptado:** La parte del codigo que muestra los clientes como widgets.
- **Rechazado / corregido:** Hubiera correcciones en la parte del layout y de la paleta de colores.
- **Verificación:** `flutter analyze` sin observaciones; `flutter test` en verde.
- **Commit / PR:** #36

## 2026-11-4 · @chrisram21 Co-authored-by: WishoSz — Fixes de formularios, pantallas y documentacion

- **Herramienta:** Claude.
- **Especificación:** Las pantallas de clientes no mostraban la opcion de marcar el producto en el que estaban interesados, eso ademas de terminar con la documentacion pendiente
- **Resultado:** Un combobox dentro de la pantlla de "Agrega cliente" y "¿Que paso?"
- **Aceptado:** Se acepto una migracion a base de datos con respecto a una funcion para cargar los datos al mismo tiempo que se crea un cliente o se hace una actualizacion de una cita 
- **Rechazado / corregido:** Hubieron correcciones al momento de realizar la documentacion faltante
- **Verificación:** `flutter analyze` sin observaciones; `flutter test` en verde.
- **Commit / PR:** #40