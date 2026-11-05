-- =============================================================================
-- Migración 6 · Producto de interés al registrar la llamada
-- =============================================================================
-- Rehace registrar_resultado_llamada con un parámetro más (p_producto).
-- Prueba: supabase/pruebas/40_producto_interes.sql (CI).
-- =============================================================================

-- Cambia la firma: se quita la de la migración 5 y se crea la nueva.
drop function registrar_resultado_llamada(uuid, resultado_llamada, text, tipo_actividad, timestamptz);

-- Todo en una transacción: si algo falla, no queda nada a medias.
-- security invoker: corre con los permisos (RLS) de quien la llama.
create function registrar_resultado_llamada(
  p_actividad       uuid,
  p_resultado       resultado_llamada,
  p_comentario      text default null,
  p_siguiente_tipo  tipo_actividad default null,
  p_siguiente_fecha timestamptz default null,
  p_producto        uuid default null
) returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  a         actividades;
  siguiente uuid;
  texto     text := nullif(trim(p_comentario), '');
begin
  update actividades
     set estado = 'completada', resultado = p_resultado, realizada_en = now()
   where id = p_actividad and estado = 'pendiente'
  returning * into a;

  if not found then
    raise exception 'La actividad no existe, no es tuya o ya no está pendiente'
      using errcode = 'P0002';
  end if;

  if texto is not null then
    insert into comentarios (cliente_id, autor_id, actividad_id, texto)
    values (a.cliente_id, auth.uid(), a.id, texto);
  end if;

  if p_siguiente_fecha is not null then
    insert into actividades
      (cliente_id, usuario_id, tipo, programada_para, nota, actividad_origen_id, creado_por)
    values
      (a.cliente_id, a.usuario_id, coalesce(p_siguiente_tipo, 'llamada'),
       p_siguiente_fecha, texto, a.id, auth.uid())
    returning id into siguiente;
  end if;

  -- La etapa sigue al resultado; "no contestó" no la cambia.
  -- Sin producto (null) se deja el que tenía.
  update clientes
     set producto_interes_id = coalesce(p_producto, producto_interes_id),
         etapa = case
           when p_resultado in ('no_interesado', 'no_volver_a_llamar') then 'perdido'
           when p_resultado = 'compro' then 'ganado'
           when p_resultado = 'pidio_cotizacion' then 'cotizado'
           when p_resultado in ('interesado', 'agendo_visita') and etapa = 'prospecto' then 'contactado'
           else etapa
         end
   where id = a.cliente_id;

  return siguiente;
end
$$;

revoke execute on function registrar_resultado_llamada(uuid, resultado_llamada, text, tipo_actividad, timestamptz, uuid) from public, anon;
grant execute on function registrar_resultado_llamada(uuid, resultado_llamada, text, tipo_actividad, timestamptz, uuid) to authenticated;
