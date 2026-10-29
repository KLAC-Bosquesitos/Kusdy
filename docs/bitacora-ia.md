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