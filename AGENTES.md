# Instrucciones para agentes de IA

Este archivo dice cómo debe trabajar cualquier agente de IA (Claude, Copilot, Cursor u otro) dentro del repositorio de Kusdy. Si algo de aquí choca con una instrucción directa de un integrante del equipo, gana la instrucción del integrante.

## 1. Antes de empezar

Lee siempre, en este orden:

1. [`CLAUDE.md`](CLAUDE.md): qué es Kusdy, alcance, decisiones técnicas y pendientes.
2. [`kusdy/SPECS.md`](kusdy/SPECS.md): fase actual, tareas abiertas y registro de avance.
3. Este archivo.

Si la tarea que te piden no corresponde a la fase actual de `SPECS.md`, avísalo antes de empezar.

## 2. Para qué sirve cada archivo

Cada cosa va en su lugar. No dupliques información entre archivos.

| Archivo | Qué contiene | Cuándo se edita |
|---|---|---|
| `CLAUDE.md` | Contexto del producto y decisiones técnicas. | Solo cuando el equipo confirma una decisión nueva o cambia el alcance. |
| `AGENTES.md` | Reglas de trabajo para agentes. | Solo si el equipo lo pide. |
| `kusdy/SPECS.md` | Fases, tareas, registro de avance y decisiones tomadas. | Al terminar una tarea o fase. |
| `kusdy/lib/` | Código de la app. | En cada tarea de desarrollo. |

## 3. Una tarea a la vez

- Trabaja solo en lo que te pidieron. No aproveches para "arreglar" otras partes, renombrar archivos ajenos ni reorganizar carpetas.
- Si ves algo que conviene cambiar fuera de la tarea, anótalo como sugerencia en tu respuesta, no lo cambies.
- Un cambio = una rama = un Pull Request. No mezcles en el mismo PR una funcionalidad, un refactor y cambios de documentación que no tengan relación.
- No toques `main` directamente. El flujo es: Issue -> Rama -> Pull Request -> Revisión -> Merge.
- No hagas commit ni push a menos que el integrante te lo pida. Por defecto deja los cambios listos para que la persona los revise.

## 4. Nombres de ramas y commits

**Propuesta** de convención:

- Ramas: `tipo/descripcion-corta`, por ejemplo `feat/login`, `fix/busqueda-clientes`, `docs/specs-fase-1`, `chore/paquetes-base`.
- Commits: `tipo: descripción en español`, por ejemplo `feat: pantalla de login`.
- Tipos: `feat` (funcionalidad), `fix` (error), `docs` (documentación), `refactor`, `test`, `chore` (configuración o dependencias).

## 5. Código

- Respeta la arquitectura por *features* de `CLAUDE.md`: `lib/features/<feature>/{data,domain,presentation}`. Lo compartido va en `lib/core/` y lo de arranque en `lib/app/`.
- Las pantallas nunca llaman a Supabase directamente. Siempre pasan por un repositorio de la capa `data`.
- Los nombres del dominio van en español (`Cliente`, `Actividad`, `Cotizacion`, `clientes_repository.dart`). Los términos técnicos de Flutter se dejan como son (`Widget`, `Provider`, `build`).
- Los colores salen solo de `KusdyColors` en `lib/app/theme.dart`. Nunca escribas un `Color(0xFF...)` suelto.
- No agregues paquetes nuevos a `pubspec.yaml` sin decir cuál y por qué. Usa los de la tabla de paquetes de `CLAUDE.md`.
- Antes de dar una tarea por terminada, corre dentro de `kusdy/`:
  - `flutter analyze` (sin errores nuevos).
  - `flutter test` (si hay pruebas).

## 6. Supabase y seguridad

- Toda tabla nueva lleva Row Level Security activa desde su creación.
- Nunca pongas la clave `service_role` ni contraseñas en el código, en commits ni en archivos de documentación. La app solo usa la clave pública.
- Los cambios de base de datos se hacen solo con migraciones SQL guardadas en el repositorio, nunca a mano desde el panel.
- **El diseño de la base de datos está en pausa.** No crees tablas ni migraciones hasta que Chris lo retome.

## 7. Decisiones y requerimientos

- No inventes requerimientos. Si algo no está en `CLAUDE.md` o en `SPECS.md`, es un pendiente: pregúntalo.
- Cuando propongas algo nuevo, márcalo como **Propuesta**. Solo el equipo lo convierte en **Decisión confirmada**.
- No amplíes el alcance hacia lo que `CLAUDE.md` marca como fuera de alcance (SaaS, roles complejos, ERP, inventario, e-commerce).

## 8. Al terminar una tarea

1. Actualiza `kusdy/SPECS.md`: marca la tarea como hecha y, si la fase cambió, actualiza el "Estado actual".
2. Agrega una entrada al "Registro de avance" con fecha, fase, qué se hizo y quién lo pidió.
3. Si se confirmó una decisión nueva, anótala en "Decisiones tomadas" de `SPECS.md` y actualiza `CLAUDE.md`.
4. Resume en tu respuesta qué archivos cambiaste y qué falta revisar.
