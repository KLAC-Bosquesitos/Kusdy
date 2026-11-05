-- =============================================================================
-- Prueba de la migración 6 (producto de interés al registrar la llamada)
-- =============================================================================
--   psql -v ON_ERROR_STOP=1 -d <base_vacia> -f supabase/pruebas/40_producto_interes.sql
-- =============================================================================

\set ON_ERROR_STOP on
\set QUIET on

\ir 00_stub_supabase.sql

\echo '1. Base con todas las migraciones'
\ir ../migrations/20261022152936_esquema_inicial.sql
\ir ../migrations/20261022153519_ajustes_advisors.sql
\ir ../migrations/20261023021135_productos_atributos.sql
\ir ../migrations/20261029160000_categorias_producto.sql
\ir ../migrations/20261103160000_registrar_resultado_llamada.sql
\ir ../migrations/20261105000000_producto_en_registro_llamada.sql

\echo '2. Datos: un vendedor, dos productos, un cliente y dos llamadas'
insert into auth.users (id, email) values ('00000000-0000-0000-0000-000000000001', 'v1@x');
insert into sucursales (id, codigo, nombre) values
  ('10000000-0000-0000-0000-000000000001', 'S01', 'Sucursal 1');
insert into perfiles (id, nombre, rol, sucursal_id) values
  ('00000000-0000-0000-0000-000000000001', 'Vendedor 1', 'vendedor', '10000000-0000-0000-0000-000000000001');
insert into productos (id, nombre, precio_lista) values
  ('30000000-0000-0000-0000-000000000001', 'Calentador 150 L', 3900),
  ('30000000-0000-0000-0000-000000000002', 'Calentador 200 L', 4900);
insert into clientes (id, vendedor_id, nombre, telefono, creado_por, producto_interes_id) values
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Cliente', '5555',
   '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001');
insert into actividades (id, cliente_id, usuario_id, tipo, programada_para, creado_por) values
  ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'llamada', now(), '00000000-0000-0000-0000-000000000001'),
  ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'llamada', now(), '00000000-0000-0000-0000-000000000001');

\echo '3. Comprobaciones (como el vendedor, con RLS)'
set role authenticated;
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';

do $$
begin
  -- "Le interesa" el 200 L: cambia el producto del cliente.
  perform registrar_resultado_llamada(
    '40000000-0000-0000-0000-000000000001', 'interesado', null, 'llamada',
    now() + interval '1 day', '30000000-0000-0000-0000-000000000002');
  assert (select producto_interes_id from clientes where id = '20000000-0000-0000-0000-000000000001')
       = '30000000-0000-0000-0000-000000000002', 'no se guardó el producto de interés';

  -- Sin producto: se queda el que tenía.
  perform registrar_resultado_llamada('40000000-0000-0000-0000-000000000002', 'no_contesto');
  assert (select producto_interes_id from clientes where id = '20000000-0000-0000-0000-000000000001')
       = '30000000-0000-0000-0000-000000000002', 'sin producto no debía cambiarlo';
end $$;
reset role;

-- La firma vieja (5 parámetros) ya no existe: solo queda una función.
do $$
begin
  assert (select count(*) from pg_proc where proname = 'registrar_resultado_llamada') = 1,
    'quedaron dos versiones de la función';
end $$;

\echo 'OK: producto de interés'
