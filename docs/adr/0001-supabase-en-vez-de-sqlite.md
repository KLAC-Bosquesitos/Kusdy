# ADR 0001 · Supabase como base de datos, no SQLite en el teléfono

- **Fecha:** 2026-10-05 (escrito en el Sprint 3)
- **Estado:** Aceptada

## Contexto

Freddy trabaja dentro y fuera de la oficina y, más adelante, sus 10 vendedores también usarán Kusdy. El jefe necesita ver los clientes de su sucursal y el gerente los de todas. Los datos de un CRM son relacionales: clientes, llamadas, comentarios, ventas, cuotas.

## Decisión

Usar **Supabase** (PostgreSQL en la nube con Auth y seguridad por filas) como única base. No guardamos una copia en SQLite en el teléfono por ahora. Cada cambio a la base es una migración SQL nueva en `supabase/migrations/`, probada en el CI sobre un Postgres 17.

## Consecuencias

- Lo que se guarda en un teléfono se ve en otro, y sigue ahí al cerrar la app.
- Los permisos viven en la base (RLS): un vendedor no puede leer clientes de otro aunque la app tuviera un error.
- Sin internet no se puede guardar. La app muestra el error con **Reintentar**. Trabajar sin conexión queda para después (fase 9).
- El plan gratuito alcanza para desarrollo; en producción cuesta unos USD 25 al mes.
