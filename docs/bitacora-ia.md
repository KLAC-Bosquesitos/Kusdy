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

## 2026-10-15 · @chrisram21 — Lab S14, Parte A (CI)

- **Herramienta:** Claude.
- **Especificación:** "Lee el PDF del Lab S14 y planifica cómo seguir con Kusdy". Después: preparar
  los archivos de CI a partir de inkash (`s14-06-ci`) con Flutter 3.44.5 y los usuarios del equipo,
  sin hacer commits (los hace el integrante tras revisar).
- **Resultado:** `ci.yml`, plantilla de PR, `CODEOWNERS`, plantilla de historia de usuario y esta bitácora.
- **Aceptado:** Solamente se verifico que los directorios utilizados en el ci.yml sean los correctos en base al proyecto y no a inkash, tambien los formatos para los PR y los permisos de los CODEOWNERS
- **Rechazado / corregido:**
  - Respecto a inkash: se agregó `working-directory: kusdy` porque la app vive en una subcarpeta;
    se quitó el paso de SQLite (Kusdy no usa sqflite); la ruta del APK se ajustó a `kusdy/build/...`.
  - Al momento de revisarn no se cambió mayor cosa ya que los directorioes estaban bien indicados.
- **Verificación:** `dart format`, `flutter analyze` y `flutter test` locales con Flutter 3.44.5; check del PR en verde.
- **Commit / PR:** https://github.com/KLAC-Bosquesitos/Kusdy/pull/12
