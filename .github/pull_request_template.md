<!-- GitHub llena este texto en cada Pull Request nuevo. Borra lo que no aplique. -->

## Qué cambia
<!-- Una o dos frases. El "por qué" importa más que el "qué". -->

Cierra #<!-- número del issue: al hacer merge, GitHub lo cierra solo -->

## Historia de usuario
<!-- HU-xx de CLAUDE.md, si aplica. -->

## Cómo probarlo
1.
2.

## Capturas
<!-- Antes / después si cambia la UI. -->

## Checklist del autor
- [ ] `dart format`, `flutter analyze` sin observaciones y `flutter test` en verde (el CI lo revisa).
- [ ] Probé en un dispositivo o emulador.
- [ ] Las pantallas no llaman a Supabase directo: todo pasa por un repositorio.
- [ ] Los colores salen de `KusdyColors`, sin `Color(0xFF...)` sueltos.
- [ ] Si la pantalla muestra datos: estados cargando, error con Reintentar, vacío y datos.
- [ ] Si usé IA: entrada en `docs/bitacora-ia.md` (qué pedí, qué acepté, qué rechacé).
- [ ] Actualicé `kusdy/SPECS.md` si terminé una tarea.

## Para quien revisa
<!-- ¿Dónde quieres que miren con más cuidado? -->
