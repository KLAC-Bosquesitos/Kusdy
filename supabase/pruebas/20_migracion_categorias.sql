-- =============================================================================
-- Prueba de la migración 4 (categorias_producto) · Lab S16
-- =============================================================================
-- Lo mismo que app_database_test en una app con SQLite: se arma una base
-- EXACTAMENTE como estaba antes (migraciones 1 a 3) con datos, se le aplica
-- la migración nueva y se comprueba que los datos siguen y que lo nuevo existe.
--
-- Corre en un Postgres vacío (el CI levanta uno):
--   psql -v ON_ERROR_STOP=1 -d <base_vacia> -f supabase/pruebas/20_migracion_categorias.sql
-- Si una comprobación falla, psql termina con error y el check del CI sale rojo.
-- =============================================================================

\set ON_ERROR_STOP on
\set QUIET on

\ir 00_stub_supabase.sql

\echo '1. Base de la versión anterior (migraciones 1 a 3)'
\ir ../migrations/20261022152936_esquema_inicial.sql
\ir ../migrations/20261022153519_ajustes_advisors.sql
\ir ../migrations/20261023021135_productos_atributos.sql

\echo '2. Datos que ya tenía esa base'
-- La migración 1 ya trae el servicio Instalación (categoría 'Servicios').
insert into productos (codigo, nombre, tipo, categoria, precio_lista) values
  ('CSG15', 'Calentador solar por gravedad 150 L', 'producto', 'Calentador solar por gravedad', 4300),
  ('CSG20', 'Calentador solar por gravedad 200 L', 'producto', 'Calentador solar por gravedad', 5300),
  ('CSP15', 'Calentador solar presurizado 150 L',  'producto', 'Calentador solar presurizado',  6500),
  ('CSP20', 'Calentador solar presurizado 200 L',  'producto', 'Calentador solar presurizado',  7500),
  -- Escrita distinto (minúsculas y espacio al final): debe caer en la misma.
  ('CSG25', 'Calentador solar por gravedad 250 L', 'producto', 'calentador solar por gravedad ', 6300),
  ('PAN400', 'Panel solar 400 W',                  'producto', 'Paneles solares',               1900),
  -- Sin categoría: debe quedar sin categoría, no inventarle una.
  ('SINCAT', 'Producto sin categoría',             'producto', null,                            100);

-- Foto de los datos ANTES de migrar, para comparar después.
create temp table antes as
  select codigo, nombre, categoria, precio_lista from productos;

\echo '3. Se aplica la migración nueva'
\ir ../migrations/20261029160000_categorias_producto.sql

\echo '4. Comprobaciones'
do $$
declare
  n int;
begin
  -- Los datos siguen: mismos productos, con los mismos datos de antes.
  select count(*) into n from productos;
  assert n = 8, format('se esperaban 8 productos y hay %s', n);
  select count(*) into n
    from antes a join productos p using (codigo)
   where p.nombre = a.nombre
     and p.precio_lista is not distinct from a.precio_lista
     and p.categoria is not distinct from a.categoria;
  assert n = 8, 'algún producto cambió de nombre, precio o categoría (texto)';

  -- Lo nuevo existe: una categoría por cada texto distinto.
  select count(*) into n from categorias_producto;
  assert n = 4, format('se esperaban 4 categorías y hay %s', n);
  assert exists (select 1 from categorias_producto where nombre = 'Paneles solares'),
    'falta la categoría Paneles solares';

  -- Cada producto quedó en SU categoría.
  select count(*) into n
    from productos p join categorias_producto c on c.id = p.categoria_id
   where lower(c.nombre) = lower(trim(p.categoria));
  assert n = 7, format('se esperaban 7 productos con categoría y hay %s', n);
  select count(*) into n
    from productos p join categorias_producto c on c.id = p.categoria_id
   where c.nombre = 'Calentador solar por gravedad';
  assert n = 3, 'los 3 de gravedad (uno escrito distinto) deben quedar juntos';
  assert (select categoria_id from productos where codigo = 'SINCAT') is null,
    'un producto sin categoría no debe recibir una';
  assert (select relrowsecurity from pg_class where relname = 'categorias_producto'),
    'categorias_producto debe tener RLS';
end $$;

\echo '5. Reglas de la tabla nueva'
do $$
declare
  servicios uuid;
  vacia uuid;
begin
  -- Nombre repetido (sin importar mayúsculas): la base lo rechaza.
  begin
    insert into categorias_producto (nombre) values ('servicios');
    raise exception 'aceptó un nombre repetido';
  exception when unique_violation then null;
  end;

  -- En uso: no se puede borrar, y sigue ahí.
  select id into servicios from categorias_producto where nombre = 'Servicios';
  begin
    delete from categorias_producto where id = servicios;
    raise exception 'borró una categoría con productos';
  exception when foreign_key_violation then null;
  end;
  assert exists (select 1 from categorias_producto where id = servicios),
    'la categoría en uso desapareció';

  -- Sin productos: sí se borra.
  insert into categorias_producto (nombre) values ('Bombas de agua') returning id into vacia;
  delete from categorias_producto where id = vacia;
  assert not exists (select 1 from categorias_producto where id = vacia),
    'no se pudo borrar una categoría vacía';

  -- Editar es un UPDATE: el id no cambia.
  update categorias_producto set nombre = 'Instalaciones' where id = servicios;
  assert (select nombre from categorias_producto where id = servicios) = 'Instalaciones',
    'editar debe conservar el id';
end $$;

\echo '6. Permisos (RLS): vendedor solo lee, gerente administra'
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'gerente@x'),
  ('00000000-0000-0000-0000-000000000001', 'vendedor@x');
insert into sucursales (id, codigo, nombre) values
  ('10000000-0000-0000-0000-000000000001', 'S01', 'Sucursal de prueba');
insert into perfiles (id, nombre, rol, sucursal_id) values
  ('00000000-0000-0000-0000-00000000000a', 'Gerente', 'gerente_general', null),
  ('00000000-0000-0000-0000-000000000001', 'Vendedor', 'vendedor', '10000000-0000-0000-0000-000000000001');

set role authenticated;
do $$
declare
  n int;
begin
  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);
  select count(*) into n from categorias_producto;
  assert n = 4, 'el vendedor debe ver las categorías';
  begin
    insert into categorias_producto (nombre) values ('Del vendedor');
    raise exception 'un vendedor pudo crear una categoría';
  exception when insufficient_privilege then null;
  end;

  perform set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000a', true);
  insert into categorias_producto (nombre) values ('Del gerente');
  assert exists (select 1 from categorias_producto where nombre = 'Del gerente'),
    'el gerente debe poder crear categorías';
end $$;
reset role;

\echo 'OK: la migración 4 conserva los datos y sus reglas funcionan.'
