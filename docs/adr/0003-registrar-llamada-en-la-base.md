# ADR 0003 · "¿Qué pasó?" se guarda con una función en la base

- **Fecha:** 2026-11-03
- **Estado:** Aceptada

## Contexto

Al tocar **Hecho**, la app guarda varias cosas: cierra la llamada con su resultado, guarda el comentario, crea la siguiente llamada o visita y puede cambiar la etapa del cliente.

## Decisión

Decidimos utilizar una función en PostgreSQL porque registrar el resultado de una llamada implica varias operaciones relacionadas: completar la actividad, guardar el comentario, crear el siguiente seguimiento cuando corresponda y actualizar la etapa del cliente. Estas operaciones deben realizarse juntas para evitar inconsistencias. Si alguna falla, la transacción revierte los cambios y evita que una llamada quede completada sin registrar el seguimiento correspondiente. Además, concentrar esta lógica en la base de datos facilita su verificación y permite respetar los permisos establecidos mediante las políticas RLS.

Una función de Postgres, `registrar_resultado_llamada(...)` (migración 5), hace todo **en una sola transacción**. La app la llama con `.rpc()`. La función usa `security invoker`, así que respeta los mismos permisos (RLS) que una consulta normal.

## Alternativa descartada

Hacer tres o cuatro llamadas desde la app. Si la red se corta después de la primera, la llamada queda cerrada **sin la siguiente**, y ese cliente se olvida, que es justo lo que Kusdy debe evitar.

## Consecuencias

- O se guarda todo, o no se guarda nada; la app muestra **Reintentar**.
- La regla vive en un solo lugar y se prueba en el CI (`supabase/pruebas/30_registrar_llamada.sql`).
- Cambiar la regla exige una migración nueva.
