-- =============================================================================
-- Kusdy · Migración 2: ajustes que pidió el Advisor de Supabase (2026-10-22)
-- =============================================================================
-- Aplicada en kusdy-dev justo después de 20261022152936_esquema_inicial.sql.
-- No cambia tablas ni reglas de negocio; solo endurece funciones y políticas.
-- =============================================================================

-- 1. search_path fijo en las funciones de trigger que no lo tenían.
alter function tocar_actualizado_en()        set search_path = public;
alter function productos_antes_de_cambiar()  set search_path = public;
alter function bloquear_mes_cerrado_ventas() set search_path = public;
alter function bloquear_mes_cerrado_pagos()  set search_path = public;

-- 2. Las funciones de trigger no se llaman por la API (/rest/v1/rpc/...).
--    El permiso EXECUTE solo se revisa al crear el trigger, así que quitarlo no los rompe.
revoke execute on function comentarios_antes_de_editar()  from public, anon, authenticated;
revoke execute on function productos_registrar_bitacora() from public, anon, authenticated;
revoke execute on function tocar_actualizado_en()         from public, anon, authenticated;
revoke execute on function productos_antes_de_cambiar()   from public, anon, authenticated;
revoke execute on function bloquear_mes_cerrado_ventas()  from public, anon, authenticated;
revoke execute on function bloquear_mes_cerrado_pagos()   from public, anon, authenticated;

-- 3. Las funciones de permisos las usan las políticas RLS del usuario con sesión,
--    así que "authenticated" las conserva. Sin sesión (anon) no las necesita.
revoke execute on function mi_rol()                              from public, anon;
revoke execute on function mi_sucursal()                         from public, anon;
revoke execute on function puede_ver(uuid)                       from public, anon;
revoke execute on function puede_ver_sucursal(uuid)              from public, anon;
revoke execute on function puede_ver_cliente(uuid)               from public, anon;
revoke execute on function puede_ver_venta(uuid)                 from public, anon;
revoke execute on function mes_esta_cerrado(uuid, timestamptz)   from public, anon;

-- 4. btree_gist fuera del esquema public (el que expone la API).
alter extension btree_gist set schema extensions;

-- 5. auth.uid() envuelto en (select ...) para que se evalúe una vez por consulta
--    y no una vez por fila (rendimiento con muchos registros).
alter policy "gerente fija hasta en" on precios_hasta_en
  with check (mi_rol() = 'gerente_general' and fijado_por = (select auth.uid()));
alter policy "crear clientes" on clientes
  with check (puede_ver(vendedor_id) and creado_por = (select auth.uid()));
alter policy "crear actividades" on actividades
  with check (puede_ver(usuario_id) and puede_ver_cliente(cliente_id) and creado_por = (select auth.uid()));
alter policy "escribir comentarios" on comentarios
  with check (autor_id = (select auth.uid()) and puede_ver_cliente(cliente_id));
alter policy "editar mis comentarios" on comentarios
  using (autor_id = (select auth.uid()) and puede_ver_cliente(cliente_id))
  with check (autor_id = (select auth.uid()));
alter policy "pedir autorizacion" on solicitudes_precio
  with check (
    solicitante_id = (select auth.uid())
    and estado = 'pendiente'
    and puede_ver_cliente(cliente_id)
    and sucursal_id = mi_sucursal()
    and jefe_id = (select jefe_id from sucursales where id = mi_sucursal())
  );
alter policy "gerente fija metas" on metas
  with check (mi_rol() = 'gerente_general' and fijada_por = (select auth.uid()));
