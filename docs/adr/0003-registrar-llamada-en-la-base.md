# ADR 0003 · "¿Qué pasó?" se guarda con una función en la base

- **Fecha:** 2026-11-03
- **Estado:** Aceptada

## Contexto

Al tocar **Hecho**, la app guarda varias cosas: cierra la llamada con su resultado, guarda el comentario, crea la siguiente llamada o visita y puede cambiar la etapa del cliente.

## Decisión

<!-- Pareja 2 (PR 2.1): completar con sus palabras. -->

Una función de Postgres, `registrar_resultado_llamada(...)` (migración 5), hace todo **en una sola transacción**. La app la llama con `.rpc()`. La función usa `security invoker`, así que respeta los mismos permisos (RLS) que una consulta normal.

## Alternativa descartada

Hacer tres o cuatro llamadas desde la app. Si la red se corta después de la primera, la llamada queda cerrada **sin la siguiente**, y ese cliente se olvida, que es justo lo que Kusdy debe evitar.

## Consecuencias

- O se guarda todo, o no se guarda nada; la app muestra **Reintentar**.
- La regla vive en un solo lugar y se prueba en el CI (`supabase/pruebas/30_registrar_llamada.sql`).
- Cambiar la regla exige una migración nueva.
