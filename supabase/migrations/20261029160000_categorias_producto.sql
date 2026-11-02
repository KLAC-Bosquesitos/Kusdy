-- =============================================================================
-- Kusdy · Migración 4: categorías de producto administrables (Lab S16)
-- =============================================================================
-- Antes la categoría era un texto suelto en productos ('Calentador solar por
-- gravedad', 'Servicios'...). Un texto no se puede renombrar en un solo lugar
-- ni impedir que se escriba de dos formas. Ahora es una tabla propia y cada
-- producto apunta a su categoría.
--
-- Regla de oro: esta migración NO edita las anteriores (ya corrieron en
-- kusdy-dev). Es aditiva: no borra columnas ni filas.
-- La prueba está en supabase/pruebas/20_migracion_categorias.sql.
-- =============================================================================

-- 1. La tabla nueva.
create table categorias_producto (
  id             uuid primary key default gen_random_uuid(),
  nombre         text not null check (length(trim(nombre)) > 0),
  -- Archivar en vez de borrar: una categoría con productos no se puede
  -- borrar (llave foránea), pero sí dejar de ofrecerse.
  archivada      boolean not null default false,
  creado_en      timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- Nombre único sin importar mayúsculas: "Servicios" y "servicios" son la misma.
create unique index categorias_producto_nombre_key
  on categorias_producto (lower(nombre));

create trigger categorias_producto_actualizado before update on categorias_producto
  for each row execute function tocar_actualizado_en();

-- 2. Pasar los datos: una categoría por cada texto distinto que ya existía.
insert into categorias_producto (nombre)
select distinct on (lower(trim(categoria))) trim(categoria)
  from productos
 where categoria is not null and trim(categoria) <> ''
 order by lower(trim(categoria)), trim(categoria);

-- 3. Cada producto apunta a su categoría. ON DELETE RESTRICT: la base no deja
--    borrar una categoría que todavía tiene productos.
alter table productos
  add column categoria_id uuid references categorias_producto (id) on delete restrict;

-- El trigger de bitácora deja un renglón por producto ("categoria_id" de
-- vacío a la categoría nueva) sin usuario: así queda registrado que lo hizo
-- la migración.
update productos p
   set categoria_id = c.id
  from categorias_producto c
 where p.categoria is not null
   and lower(c.nombre) = lower(trim(p.categoria));

create index productos_categoria_idx on productos (categoria_id);

-- La columna vieja productos.categoria se queda: borrarla en la misma
-- migración rompería cualquier versión de la app que todavía la lea. Se
-- quita en una migración futura, cuando ya nadie la use.
comment on column productos.categoria is
  'Obsoleta desde la migración 4: usar categoria_id. Se borrará más adelante.';

-- 4. Seguridad: igual que productos. Todos ven; jefe, supervisor y gerente
--    crean, editan y borran (borrar solo funciona si no tiene productos).
alter table categorias_producto enable row level security;

create policy "ver categorias de producto" on categorias_producto
  for select to authenticated using (true);
create policy "crear categorias de producto" on categorias_producto
  for insert to authenticated
  with check (mi_rol() in ('jefe_sucursal', 'supervisor', 'gerente_general'));
create policy "editar categorias de producto" on categorias_producto
  for update to authenticated
  using (mi_rol() in ('jefe_sucursal', 'supervisor', 'gerente_general'));
create policy "borrar categorias de producto" on categorias_producto
  for delete to authenticated
  using (mi_rol() in ('jefe_sucursal', 'supervisor', 'gerente_general'));
