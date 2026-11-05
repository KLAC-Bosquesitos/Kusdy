# Pruebas con usuarios

Cada persona probó el APK de `main` en un teléfono, sin ayuda, con las tareas de abajo. Anotamos qué intentó, qué falló y qué PR lo arregló.

## Tareas

1. Buscar a un cliente por su nombre.
2. Agregar un cliente nuevo con nombre y teléfono.
3. Ver los comentarios de un cliente y dejar uno nuevo.
4. Marcar como hecha una llamada de hoy: no contestó, volver a llamar mañana.
5. Encontrar esa llamada en la Agenda de mañana.

## Resultados

| # | Quién (rol) | Fecha | Qué intentó | Qué falló o le costó | Qué dijo | PR que lo arregló |
|---|---|---|---|---|---|---|
| 1 | Freddy (jefe de sucursal) | 3/11/2026|Las 5 tareas de arriba | Le costó leer algunas enunciados |Dijo que estaba bonito pero que le gustaria que los titulos fueran mas grandes |#40 |
| 2 |Amilcar Alonzo (vendedor) |1/11/2026|Las 5 tareas de arriba |Lo mismo que a Freddy, la lectura de ciertos titulos |Dijo que le gusta la interfaz y que le gustaria comenzar a usarlo |#40 |
| 3 | Mirna Ardiano (vendedor) | 23/10/2026 | Las 5 tareas de arriba | Le costó leer ciertos títulos | Le gusta la interfaz, pero le gustaría un calendario | #23 |

## Cambios pedidos antes de esta prueba

Freddy revisó los diseños el 2026-10-22. Lo que cambiamos por lo que dijo:

| Pedido de Freddy | Qué hicimos | PR |
|---|---|---|
| El último comentario siempre a la vista, en una tarjeta aparte | Tarjeta de Comentarios en el detalle del cliente | #36 |
| Después de "Hecho", que la app pregunte qué pasó y ofrezca lo siguiente | Pantalla "¿Qué pasó?" | #38 |
| Avisar cuando un cliente no contesta varias veces | Aviso de 3 llamadas sin respuesta | #38 |
