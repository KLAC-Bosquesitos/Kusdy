-- =============================================================================
-- Prueba de la migración 5 (registrar_resultado_llamada)
-- =============================================================================
-- Corre en un Postgres vacío (el CI levanta uno):
--   psql -v ON_ERROR_STOP=1 -d <base_vacia> -f supabase/pruebas/30_registrar_llamada.sql
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

\echo '2. Datos: un vendedor, otro de otra sucursal, un cliente y una llamada'
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000001', 'v1@x'),
  ('00000000-0000-0000-0000-000000000003', 'v3@x');
insert into sucursales (id, codigo, nombre) values
  ('10000000-0000-0000-0000-000000000001', 'S01', 'Sucursal 1'),
  ('10000000-0000-0000-0000-000000000002', 'S02', 'Sucursal 2');
insert into perfiles (id, nombre, rol, sucursal_id) values
  ('00000000-0000-0000-0000-000000000001', 'Vendedor 1', 'vendedor', '10000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000003', 'Vendedor 3', 'vendedor', '10000000-0000-0000-0000-000000000002');
insert into clientes (id, vendedor_id, nombre, telefono, creado_por) values
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Cliente', '5555', '00000000-0000-0000-0000-000000000001');
insert into actividades (id, cliente_id, usuario_id, tipo, programada_para, creado_por) values
  ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'llamada', now(), '00000000-0000-0000-0000-000000000001'),
  ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'llamada', now(), '00000000-0000-0000-0000-000000000001'),
  ('40000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'llamada', now(), '00000000-0000-0000-0000-000000000001');

\echo '3. Comprobaciones (como el vendedor 1, con RLS)'
set role authenticated;
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';

do $$
declare
  sig uuid;
  n   int;
  a   actividades;
begin
  -- No contestó + volver a llamar mañana.
  sig := registrar_resultado_llamada(
    '40000000-0000-0000-0000-000000000001', 'no_contesto',
    '  Sonó y no contestó  ', 'llamada', now() + interval '1 day');

  select * into a from actividades where id = '40000000-0000-0000-0000-000000000001';
  assert a.estado = 'completada' and a.resultado = 'no_contesto' and a.realizada_en is not null,
    'la llamada no quedó completada con su resultado';

  select * into a from actividades where id = sig;
  assert a.estado = 'pendiente' and a.actividad_origen_id = '40000000-0000-0000-0000-000000000001'
     and a.nota = 'Sonó y no contestó', 'la siguiente llamada no quedó bien';

  select count(*) into n from comentarios where actividad_id = '40000000-0000-0000-0000-000000000001'
     and texto = 'Sonó y no contestó';
  assert n = 1, 'no se guardó el comentario (sin espacios)';

  assert (select etapa from clientes where id = '20000000-0000-0000-0000-000000000001') = 'prospecto',
    '"no contestó" no debe cambiar la etapa';

  -- Repetir sobre la misma actividad falla: ya no está pendiente.
  begin
    perform registrar_resultado_llamada('40000000-0000-0000-0000-000000000001', 'interesado');
    assert false, 'registrar dos veces debía fallar';
  exception when sqlstate 'P0002' then null;
  end;

  -- "No le interesa" sin siguiente: cliente perdido, sin actividad nueva.
  select count(*) into n from actividades;
  sig := registrar_resultado_llamada('40000000-0000-0000-0000-000000000002', 'no_interesado');
  assert sig is null, 'sin fecha no debe crear siguiente';
  assert (select count(*) from actividades) = n, 'se creó una actividad de más';
  assert (select etapa from clientes where id = '20000000-0000-0000-0000-000000000001') = 'perdido',
    '"no le interesa" debe dejar al cliente perdido';
end $$;

-- Otro vendedor no puede cerrar la llamada del vendedor 1 (RLS).
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000003';
do $$
begin
  perform registrar_resultado_llamada('40000000-0000-0000-0000-000000000009', 'compro');
  assert false, 'otro vendedor no debía poder registrar';
exception when sqlstate 'P0002' then null;
end $$;

reset role;
\echo '4. Transacción: si falla el comentario, la llamada sigue pendiente'
-- Se simula una falla a la mitad: guardar el comentario da error.
create function falla_comentario() returns trigger language plpgsql as
$$ begin raise exception 'falla simulada'; end $$;
create trigger falla_comentario before insert on comentarios
  for each row execute function falla_comentario();

set role authenticated;
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';
do $$
begin
  begin
    perform registrar_resultado_llamada(
      '40000000-0000-0000-0000-000000000009', 'interesado', 'Le interesa', 'visita', now() + interval '2 day');
    assert false, 'debía fallar por el comentario';
  exception when raise_exception then null;
  end;
  assert (select estado from actividades where id = '40000000-0000-0000-0000-000000000009') = 'pendiente',
    'la llamada quedó cerrada aunque falló el comentario';
  assert not exists (select 1 from actividades where actividad_origen_id = '40000000-0000-0000-0000-000000000009'),
    'quedó una visita creada a medias';
end $$;
reset role;

\echo 'OK: registrar_resultado_llamada'
