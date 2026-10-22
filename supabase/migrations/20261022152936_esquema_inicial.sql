-- =============================================================================
-- Kusdy · Migración 1: esquema inicial (v2, 2026-10-22)
-- =============================================================================
-- Documento explicativo: docs/bd/diseno-bd-v2.md
-- Estado: APLICADA en kusdy-dev (2026-10-22). Le sigue 20261022153519_ajustes_advisors.sql.
-- Versión en kusdy-dev: 20261022152936 (el nombre del archivo coincide con ella)
--
-- Reglas que sigue este archivo:
--   * Todas las tablas tienen RLS activa. Sin una política, nadie lee ni escribe.
--   * Las políticas son solo para el rol "authenticated": sin sesión no se ve nada.
--   * Nada se borra: clientes, perfiles, productos y ventas se desactivan o anulan.
--   * Dinero en numeric(12,2) y siempre en quetzales (GTQ).
--   * Fechas con zona horaria (timestamptz); los meses se cortan en America/Guatemala.
--   * Las operaciones de varios pasos (registrar venta, resultado de llamada,
--     responder solicitud, cerrar mes) van en migraciones de su fase como funciones
--     SQL. Son aditivas: no cambian estas tablas.
-- =============================================================================

create extension if not exists btree_gist;  -- para impedir rangos "hasta en" encimados


-- -----------------------------------------------------------------------------
-- 1. Tipos (listas cerradas)
-- -----------------------------------------------------------------------------

create type rol_usuario as enum (
  'instalador', 'vendedor', 'jefe_sucursal', 'supervisor', 'gerente_general'
);

create type tipo_cliente as enum ('final', 'mayorista');

create type etapa_cliente as enum (
  'prospecto', 'contactado', 'cotizado', 'ganado', 'perdido'
);

create type tipo_actividad as enum (
  'llamada', 'cita', 'visita', 'instalacion', 'seguimiento'
);

create type estado_actividad as enum ('pendiente', 'completada', 'cancelada');

-- Validada con Fredy (2026-10-22). Agregar un valor después es una migración
-- pequeña: alter type resultado_llamada add value '...';
create type resultado_llamada as enum (
  'no_contesto', 'no_interesado', 'interesado', 'pidio_cotizacion',
  'agendo_visita', 'compro', 'numero_equivocado', 'no_volver_a_llamar'
);

create type tipo_producto as enum ('producto', 'servicio');

create type tipo_solicitud as enum ('descuento', 'instalacion');

create type estado_solicitud as enum ('pendiente', 'aprobada', 'rechazada', 'usada');

create type estado_venta as enum ('registrada', 'anulada');


-- -----------------------------------------------------------------------------
-- 2. Organización: sucursales y perfiles
-- -----------------------------------------------------------------------------

-- Una sucursal es también el "grupo de ventas" de los reportes.
create table sucursales (
  id                  uuid primary key default gen_random_uuid(),
  codigo              text not null unique,          -- prefijo del número de venta, ej. 'S01'
  nombre              text not null,
  ciudad              text,
  jefe_id             uuid,                          -- FK a perfiles, se agrega abajo
  supervisor_id       uuid,                          -- FK a perfiles, se agrega abajo
  ultimo_numero_venta integer not null default 0,    -- contador del correlativo por sucursal
  activo              boolean not null default true,
  creado_en           timestamptz not null default now(),
  actualizado_en      timestamptz not null default now()
);

-- Supabase Auth guarda correo y contraseña en auth.users; aquí va el resto.
create table perfiles (
  id             uuid primary key references auth.users (id),
  nombre         text not null,
  telefono       text,
  rol            rol_usuario not null,
  sucursal_id    uuid references sucursales (id),
  activo         boolean not null default true,
  creado_en      timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  -- supervisor y gerente general están por encima de las sucursales;
  -- todos los demás pertenecen a una.
  constraint perfiles_sucursal_segun_rol check (
    (rol in ('supervisor', 'gerente_general')) = (sucursal_id is null)
  )
);

alter table sucursales
  add constraint sucursales_jefe_fk       foreign key (jefe_id)       references perfiles (id),
  add constraint sucursales_supervisor_fk foreign key (supervisor_id) references perfiles (id);

create index perfiles_sucursal_idx on perfiles (sucursal_id);


-- -----------------------------------------------------------------------------
-- 3. Catálogos: productos, bitácora, "hasta en", métodos de pago
-- -----------------------------------------------------------------------------

-- PROVISIONAL: los atributos definitivos se ajustan cuando Chris traiga los datos
-- reales (categoría, capacidad/modelo, código). Las relaciones no cambian.
create table productos (
  id              uuid primary key default gen_random_uuid(),
  codigo          text unique,                        -- SKU interno, si existe
  nombre          text not null,
  tipo            tipo_producto not null default 'producto',
  categoria       text,                               -- ej. 'Calentadores', 'Paneles'
  descripcion     text,
  precio_lista    numeric(12,2) check (precio_lista >= 0),
  activo          boolean not null default true,
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now(),
  actualizado_por uuid references perfiles (id),
  -- Los productos llevan precio de lista; un servicio como la instalación no.
  constraint productos_precio_segun_tipo check (tipo = 'servicio' or precio_lista is not null)
);

-- Un renglón por cada campo que cambia. La llena el trigger de la sección 8.
create table productos_bitacora (
  id             bigint generated always as identity primary key,
  producto_id    uuid not null references productos (id),
  campo          text not null,
  valor_anterior text,
  valor_nuevo    text,
  cambiado_por   uuid references perfiles (id),
  cambiado_en    timestamptz not null default now()
);

create index productos_bitacora_producto_idx on productos_bitacora (producto_id, cambiado_en desc);

-- Precio mínimo del periodo, igual para las 5 sucursales. Lo fija el gerente general.
create table precios_hasta_en (
  id            uuid primary key default gen_random_uuid(),
  producto_id   uuid not null references productos (id),
  precio_minimo numeric(12,2) not null check (precio_minimo >= 0),
  vigente_desde date not null,
  vigente_hasta date not null,
  fijado_por    uuid not null references perfiles (id),
  creado_en     timestamptz not null default now(),
  constraint precios_hasta_en_rango check (vigente_hasta >= vigente_desde),
  -- Un producto no puede tener dos "hasta en" vigentes el mismo día.
  constraint precios_hasta_en_sin_traslape exclude using gist (
    producto_id with =,
    daterange(vigente_desde, vigente_hasta, '[]') with &&
  )
);

create table metodos_pago (
  id         uuid primary key default gen_random_uuid(),
  codigo     text not null unique,
  nombre     text not null,
  es_credito boolean not null default false,   -- si es crédito, la venta genera cuotas
  activo     boolean not null default true,
  creado_en  timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 4. Clientes, actividades y comentarios
-- -----------------------------------------------------------------------------

create table clientes (
  id                  uuid primary key default gen_random_uuid(),
  vendedor_id         uuid not null references perfiles (id),   -- asignado; se puede reasignar
  nombre              text not null,
  telefono            text not null,
  telefono_alt        text,
  correo              text,
  direccion           text,
  ciudad              text,
  tipo                tipo_cliente not null default 'final',
  etapa               etapa_cliente not null default 'prospecto',
  producto_interes_id uuid references productos (id),
  origen              text,                    -- recomendación, feria, redes...
  nota_fija           text,                    -- dato fijo opcional; los comentarios van aparte
  creado_por          uuid not null references perfiles (id),
  creado_en           timestamptz not null default now(),
  actualizado_en      timestamptz not null default now(),
  eliminado_en        timestamptz              -- borrado lógico
);

create index clientes_vendedor_idx on clientes (vendedor_id) where eliminado_en is null;
create index clientes_creado_en_idx on clientes (creado_en);        -- filtro por mes de registro
create index clientes_ciudad_idx on clientes (ciudad);

create table actividades (
  id                  uuid primary key default gen_random_uuid(),
  cliente_id          uuid not null references clientes (id),
  usuario_id          uuid not null references perfiles (id),   -- responsable / quien la hizo
  tipo                tipo_actividad not null,
  programada_para     timestamptz,
  recordar_en         timestamptz,
  realizada_en        timestamptz,
  estado              estado_actividad not null default 'pendiente',
  resultado           resultado_llamada,
  instalador_id       uuid references perfiles (id),            -- instaladores: fuera de la v1
  actividad_origen_id uuid references actividades (id),         -- de qué actividad salió esta
  creado_por          uuid not null references perfiles (id),
  creado_en           timestamptz not null default now(),
  actualizado_en      timestamptz not null default now(),
  constraint actividades_resultado_al_completar check (resultado is null or estado = 'completada'),
  constraint actividades_instalador_solo_instalacion check (instalador_id is null or tipo = 'instalacion')
);

-- La consulta más frecuente de la app: "mis pendientes de hoy" (Hoy y Agenda).
create index actividades_pendientes_idx on actividades (usuario_id, estado, programada_para);
create index actividades_cliente_idx on actividades (cliente_id, realizada_en desc);

-- Su autor los puede editar (pedido de Chris); no se borran. Cada edición
-- deja el texto anterior en comentarios_ediciones.
create table comentarios (
  id           uuid primary key default gen_random_uuid(),
  cliente_id   uuid not null references clientes (id),
  autor_id     uuid not null references perfiles (id),
  actividad_id uuid references actividades (id),
  texto        text not null check (length(trim(texto)) > 0),
  creado_en    timestamptz not null default now(),
  editado_en   timestamptz                      -- la app muestra "(editado)"
);

create index comentarios_cliente_idx on comentarios (cliente_id, creado_en desc);

create table comentarios_ediciones (
  id             bigint generated always as identity primary key,
  comentario_id  uuid not null references comentarios (id),
  texto_anterior text not null,
  editado_por    uuid references perfiles (id),
  editado_en     timestamptz not null default now()
);

create index comentarios_ediciones_idx on comentarios_ediciones (comentario_id, editado_en desc);


-- -----------------------------------------------------------------------------
-- 5. Solicitudes de precio (descuento bajo el "hasta en" o precio de instalación)
-- -----------------------------------------------------------------------------

-- Se piden antes de la venta, las responde el jefe de la sucursal y no vencen.
create table solicitudes_precio (
  id                  uuid primary key default gen_random_uuid(),
  tipo                tipo_solicitud not null,
  sucursal_id         uuid not null references sucursales (id),
  cliente_id          uuid not null references clientes (id),
  producto_id         uuid not null references productos (id),
  solicitante_id      uuid not null references perfiles (id),
  jefe_id             uuid not null references perfiles (id),
  precio_lista        numeric(12,2),            -- copia al momento de pedir
  hasta_en            numeric(12,2),            -- copia al momento de pedir
  precio_solicitado   numeric(12,2) not null check (precio_solicitado >= 0),
  motivo              text not null,
  estado              estado_solicitud not null default 'pendiente',
  respondida_por      uuid references perfiles (id),
  respondida_en       timestamptz,
  comentario_respuesta text,
  creado_en           timestamptz not null default now()
);

create index solicitudes_jefe_idx on solicitudes_precio (jefe_id, estado);
create index solicitudes_solicitante_idx on solicitudes_precio (solicitante_id, estado);


-- -----------------------------------------------------------------------------
-- 6. Ventas, líneas, cuotas y pagos
-- -----------------------------------------------------------------------------

create table ventas (
  id               uuid primary key default gen_random_uuid(),
  numero           text not null unique,                  -- ej. 'S01-000123', por sucursal
  sucursal_id      uuid not null references sucursales (id),  -- copia al momento de vender
  cliente_id       uuid not null references clientes (id),
  vendedor_id      uuid not null references perfiles (id),
  fecha            timestamptz not null default now(),
  total            numeric(12,2) not null check (total >= 0),
  numero_cuotas    integer check (numero_cuotas > 0),     -- solo ventas a crédito
  estado           estado_venta not null default 'registrada',
  comentario       text,
  anulada_por      uuid references perfiles (id),
  anulada_en       timestamptz,
  motivo_anulacion text,
  registrada_por   uuid not null references perfiles (id),
  creado_en        timestamptz not null default now(),
  constraint ventas_anulacion_completa check (
    (estado = 'anulada') = (anulada_en is not null and motivo_anulacion is not null)
  )
);

create index ventas_vendedor_fecha_idx on ventas (vendedor_id, fecha);
create index ventas_sucursal_fecha_idx on ventas (sucursal_id, fecha);
create index ventas_cliente_idx on ventas (cliente_id);

create table venta_lineas (
  id                  uuid primary key default gen_random_uuid(),
  venta_id            uuid not null references ventas (id),
  producto_id         uuid not null references productos (id),
  cantidad            integer not null default 1 check (cantidad > 0),
  precio_lista        numeric(12,2),             -- copia al vender (null en servicios)
  hasta_en            numeric(12,2),             -- copia del "hasta en" vigente al vender
  precio_unitario     numeric(12,2) not null check (precio_unitario >= 0),
  subtotal            numeric(12,2) generated always as (cantidad * precio_unitario) stored,
  detalle             text,                      -- ej. "incluye estructura metálica"
  solicitud_id        uuid references solicitudes_precio (id),
  autorizado_por_jefe boolean not null default false  -- vendió el propio jefe bajo el mínimo
);

create index venta_lineas_venta_idx on venta_lineas (venta_id);
create index venta_lineas_producto_idx on venta_lineas (producto_id);

create table cuotas (
  id       uuid primary key default gen_random_uuid(),
  venta_id uuid not null references ventas (id),
  numero   integer not null check (numero > 0),
  monto    numeric(12,2) not null check (monto > 0),
  vence_el date not null,
  unique (venta_id, numero)
);

create index cuotas_vence_idx on cuotas (vence_el);

create table pagos (
  id             uuid primary key default gen_random_uuid(),
  venta_id       uuid not null references ventas (id),
  cuota_id       uuid references cuotas (id),      -- abono de crédito
  metodo_pago_id uuid not null references metodos_pago (id),
  monto          numeric(12,2) not null check (monto > 0),
  fecha_pago     timestamptz not null default now(),
  registrado_por uuid not null references perfiles (id),
  creado_en      timestamptz not null default now()
);

create index pagos_venta_idx on pagos (venta_id);
create index pagos_fecha_idx on pagos (fecha_pago);   -- los reportes cuentan lo cobrado


-- -----------------------------------------------------------------------------
-- 7. Metas y cierres mensuales
-- -----------------------------------------------------------------------------

-- "mes" siempre es el día 1 del mes, ej. 2026-11-01.
create table metas (
  id          uuid primary key default gen_random_uuid(),
  sucursal_id uuid not null references sucursales (id),
  mes         date not null check (extract(day from mes) = 1),
  monto       numeric(12,2) not null check (monto > 0),
  fijada_por  uuid not null references perfiles (id),
  creado_en   timestamptz not null default now(),
  unique (sucursal_id, mes)
);

-- Foto del reporte al cerrar el mes. Una vez creada no cambia.
create table cierres_mensuales (
  id             uuid primary key default gen_random_uuid(),
  sucursal_id    uuid not null references sucursales (id),
  mes            date not null check (extract(day from mes) = 1),
  meta           numeric(12,2),
  total_cobrado  numeric(12,2) not null,
  total_vendido  numeric(12,2) not null,
  numero_ventas  integer not null,
  detalle        jsonb not null default '{}',   -- por vendedor, producto y método de pago
  cerrado_por    uuid not null references perfiles (id),
  cerrado_en     timestamptz not null default now(),
  unique (sucursal_id, mes)
);


-- -----------------------------------------------------------------------------
-- 8. Funciones de apoyo y triggers
-- -----------------------------------------------------------------------------

-- security definer: corren con permisos del dueño para poder leer perfiles y
-- sucursales sin caer en un ciclo de políticas RLS. search_path fijo por seguridad.

create function mi_rol() returns rol_usuario
language sql stable security definer set search_path = public as $$
  select rol from perfiles where id = auth.uid() and activo
$$;

create function mi_sucursal() returns uuid
language sql stable security definer set search_path = public as $$
  select sucursal_id from perfiles where id = auth.uid() and activo
$$;

-- ¿Puedo ver lo que pertenece a la sucursal s?
create function puede_ver_sucursal(s uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from perfiles where id = auth.uid() and activo and rol = 'gerente_general')
      or exists (
        select 1 from sucursales su
        where su.id = s
          and (su.jefe_id = auth.uid() or su.supervisor_id = auth.uid())
      )
$$;

-- ¿Puedo ver lo que pertenece al usuario "dueno"? La regla central de Kusdy:
-- es mío · soy jefe o supervisor de su sucursal · soy gerente general.
create function puede_ver(dueno uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select dueno = auth.uid()
      or exists (select 1 from perfiles where id = auth.uid() and activo and rol = 'gerente_general')
      or exists (
        select 1
        from perfiles p
        join sucursales su on su.id = p.sucursal_id
        where p.id = dueno
          and (su.jefe_id = auth.uid() or su.supervisor_id = auth.uid())
      )
$$;

create function puede_ver_cliente(c uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from clientes where id = c and puede_ver(vendedor_id))
$$;

create function puede_ver_venta(v uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from ventas where id = v and puede_ver(vendedor_id))
$$;

-- Mantiene actualizado_en al día en cada update.
create function tocar_actualizado_en() returns trigger
language plpgsql as $$
begin
  new.actualizado_en := now();
  return new;
end;
$$;

create trigger sucursales_actualizado before update on sucursales
  for each row execute function tocar_actualizado_en();
create trigger perfiles_actualizado before update on perfiles
  for each row execute function tocar_actualizado_en();
create trigger clientes_actualizado before update on clientes
  for each row execute function tocar_actualizado_en();
create trigger actividades_actualizado before update on actividades
  for each row execute function tocar_actualizado_en();

-- Productos: marca quién cambió y deja un renglón en la bitácora por cada campo.
create function productos_antes_de_cambiar() returns trigger
language plpgsql as $$
begin
  new.actualizado_en := now();
  new.actualizado_por := auth.uid();
  return new;
end;
$$;

create trigger productos_actualizado before update on productos
  for each row execute function productos_antes_de_cambiar();

create function productos_registrar_bitacora() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  campo text;
  antes jsonb := to_jsonb(old);
  despues jsonb := to_jsonb(new);
begin
  for campo in select jsonb_object_keys(despues) loop
    if campo not in ('actualizado_en', 'actualizado_por')
       and antes -> campo is distinct from despues -> campo then
      insert into productos_bitacora (producto_id, campo, valor_anterior, valor_nuevo, cambiado_por)
      values (new.id, campo, antes ->> campo, despues ->> campo, auth.uid());
    end if;
  end loop;
  return new;
end;
$$;

create trigger productos_bitacora_trg after update on productos
  for each row execute function productos_registrar_bitacora();

-- Comentarios: solo cambia el texto, y el anterior queda guardado.
create function comentarios_antes_de_editar() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.cliente_id is distinct from old.cliente_id
     or new.autor_id is distinct from old.autor_id
     or new.actividad_id is distinct from old.actividad_id
     or new.creado_en is distinct from old.creado_en then
    raise exception 'De un comentario solo se puede editar el texto.';
  end if;
  if new.texto is distinct from old.texto then
    insert into comentarios_ediciones (comentario_id, texto_anterior, editado_por)
    values (old.id, old.texto, auth.uid());
    new.editado_en := now();
  end if;
  return new;
end;
$$;

create trigger comentarios_editar before update on comentarios
  for each row execute function comentarios_antes_de_editar();

-- Mes cerrado: impide crear, cambiar o anular ventas y pagos de un mes que ya cerró.
create function mes_esta_cerrado(sucursal uuid, momento timestamptz) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from cierres_mensuales
    where sucursal_id = sucursal
      and mes = date_trunc('month', momento at time zone 'America/Guatemala')::date
  )
$$;

create function bloquear_mes_cerrado_ventas() returns trigger
language plpgsql as $$
begin
  if mes_esta_cerrado(coalesce(new.sucursal_id, old.sucursal_id), coalesce(old.fecha, new.fecha)) then
    raise exception 'El mes de esta venta ya fue cerrado; no se puede modificar.';
  end if;
  return new;
end;
$$;

create trigger ventas_mes_cerrado before insert or update on ventas
  for each row execute function bloquear_mes_cerrado_ventas();

create function bloquear_mes_cerrado_pagos() returns trigger
language plpgsql as $$
declare
  sucursal uuid;
begin
  select sucursal_id into sucursal from ventas where id = coalesce(new.venta_id, old.venta_id);
  if mes_esta_cerrado(sucursal, coalesce(old.fecha_pago, new.fecha_pago)) then
    raise exception 'El mes de este pago ya fue cerrado; no se puede modificar.';
  end if;
  return new;
end;
$$;

create trigger pagos_mes_cerrado before insert or update on pagos
  for each row execute function bloquear_mes_cerrado_pagos();

-- Siguiente número de venta de una sucursal, ej. 'S01-000124'.
-- El update bloquea la fila de la sucursal hasta que termine la transacción,
-- así dos ventas simultáneas nunca reciben el mismo número.
-- Solo la usará registrar_venta (fase 5); no se expone a la app.
create function siguiente_numero_venta(sucursal uuid) returns text
language plpgsql security definer set search_path = public as $$
declare
  resultado text;
begin
  update sucursales
     set ultimo_numero_venta = ultimo_numero_venta + 1
   where id = sucursal
  returning codigo || '-' || lpad(ultimo_numero_venta::text, 6, '0') into resultado;
  if resultado is null then
    raise exception 'Sucursal % no existe', sucursal;
  end if;
  return resultado;
end;
$$;

revoke execute on function siguiente_numero_venta(uuid) from public, anon, authenticated;


-- -----------------------------------------------------------------------------
-- 9. Vistas (respetan RLS de quien consulta gracias a security_invoker)
-- -----------------------------------------------------------------------------

-- Lo que necesita la lista de clientes para filtrar y ordenar (punto 1).
create view clientes_resumen with (security_invoker = true) as
select
  c.*,
  ult.resultado                     as ultimo_resultado,
  ult.realizada_en                  as ultimo_contacto,
  prox.programada_para              as proxima_llamada,
  coalesce(sin_resp.intentos, 0)    as intentos_sin_respuesta,
  (ult.resultado = 'no_contesto')   as no_contesto
from clientes c
left join lateral (
  select a.resultado, a.realizada_en
  from actividades a
  where a.cliente_id = c.id and a.tipo = 'llamada' and a.estado = 'completada'
  order by a.realizada_en desc
  limit 1
) ult on true
left join lateral (
  select min(a.programada_para) as programada_para
  from actividades a
  where a.cliente_id = c.id and a.estado = 'pendiente'
) prox on true
left join lateral (
  -- llamadas seguidas sin respuesta desde la última que sí se contestó
  select count(*) as intentos
  from actividades a
  where a.cliente_id = c.id and a.tipo = 'llamada' and a.estado = 'completada'
    and a.resultado = 'no_contesto'
    and a.realizada_en > coalesce((
      select max(b.realizada_en) from actividades b
      where b.cliente_id = c.id and b.tipo = 'llamada' and b.estado = 'completada'
        and b.resultado <> 'no_contesto'
    ), '-infinity')
) sin_resp on true
where c.eliminado_en is null;

-- Saldo de cada cuota y si está atrasada (Hoy, Agenda y detalle de la venta).
create view cuotas_estado with (security_invoker = true) as
select
  q.*,
  v.cliente_id,
  v.vendedor_id,
  coalesce(p.pagado, 0)                         as pagado,
  q.monto - coalesce(p.pagado, 0)               as saldo,
  (q.monto - coalesce(p.pagado, 0) <= 0)        as pagada,
  (q.monto - coalesce(p.pagado, 0) > 0
     and q.vence_el < (now() at time zone 'America/Guatemala')::date) as atrasada
from cuotas q
join ventas v on v.id = q.venta_id and v.estado = 'registrada'
left join lateral (
  select sum(monto) as pagado from pagos where cuota_id = q.id
) p on true;


-- -----------------------------------------------------------------------------
-- 10. Row Level Security
-- -----------------------------------------------------------------------------
-- Escritura directa desde la app solo donde es seguro. Lo delicado (ventas,
-- pagos, responder solicitudes, cerrar mes, crear usuarios) pasa por funciones
-- SQL o por la Edge Function crear_usuario, que validan las reglas del negocio.

alter table sucursales          enable row level security;
alter table perfiles            enable row level security;
alter table productos           enable row level security;
alter table productos_bitacora  enable row level security;
alter table precios_hasta_en    enable row level security;
alter table metodos_pago        enable row level security;
alter table clientes            enable row level security;
alter table actividades         enable row level security;
alter table comentarios         enable row level security;
alter table comentarios_ediciones enable row level security;
alter table solicitudes_precio  enable row level security;
alter table ventas              enable row level security;
alter table venta_lineas        enable row level security;
alter table cuotas              enable row level security;
alter table pagos               enable row level security;
alter table metas               enable row level security;
alter table cierres_mensuales   enable row level security;

-- Sucursales: todos ven la lista; solo el gerente general la cambia.
create policy "ver sucursales" on sucursales for select to authenticated using (true);
create policy "gerente crea sucursales" on sucursales for insert to authenticated
  with check (mi_rol() = 'gerente_general');
create policy "gerente edita sucursales" on sucursales for update to authenticated
  using (mi_rol() = 'gerente_general');

-- Perfiles: veo el mío y los de quienes tengo a cargo. Altas y cambios de rol
-- solo por la Edge Function crear_usuario (usa la clave de servicio).
create policy "ver perfiles" on perfiles for select to authenticated
  using (puede_ver(id));

-- Productos: todos los ven; jefe, supervisor y gerente los crean y editan.
create policy "ver productos" on productos for select to authenticated using (true);
create policy "crear productos" on productos for insert to authenticated
  with check (mi_rol() in ('jefe_sucursal', 'supervisor', 'gerente_general'));
create policy "editar productos" on productos for update to authenticated
  using (mi_rol() in ('jefe_sucursal', 'supervisor', 'gerente_general'));

create policy "ver bitacora de productos" on productos_bitacora for select to authenticated
  using (mi_rol() in ('jefe_sucursal', 'supervisor', 'gerente_general'));

-- "Hasta en": todos lo ven (la app lo muestra al vender); solo el gerente general lo fija.
create policy "ver hasta en" on precios_hasta_en for select to authenticated using (true);
create policy "gerente fija hasta en" on precios_hasta_en for insert to authenticated
  with check (mi_rol() = 'gerente_general' and fijado_por = auth.uid());
create policy "gerente corrige hasta en" on precios_hasta_en for update to authenticated
  using (mi_rol() = 'gerente_general');

-- Métodos de pago: casi fijos; agregar o desactivar uno es de supervisor o gerente.
create policy "ver metodos de pago" on metodos_pago for select to authenticated using (true);
create policy "agregar metodo de pago" on metodos_pago for insert to authenticated
  with check (mi_rol() in ('supervisor', 'gerente_general'));
create policy "desactivar metodo de pago" on metodos_pago for update to authenticated
  using (mi_rol() in ('supervisor', 'gerente_general'));

-- Clientes: los míos o los de quienes tengo a cargo. Sin delete: borrado lógico.
create policy "ver clientes" on clientes for select to authenticated
  using (puede_ver(vendedor_id));
create policy "crear clientes" on clientes for insert to authenticated
  with check (puede_ver(vendedor_id) and creado_por = auth.uid());
create policy "editar clientes" on clientes for update to authenticated
  using (puede_ver(vendedor_id)) with check (puede_ver(vendedor_id));

-- Actividades: mismas reglas, por el responsable.
create policy "ver actividades" on actividades for select to authenticated
  using (puede_ver(usuario_id));
create policy "crear actividades" on actividades for insert to authenticated
  with check (puede_ver(usuario_id) and puede_ver_cliente(cliente_id) and creado_por = auth.uid());
create policy "editar actividades" on actividades for update to authenticated
  using (puede_ver(usuario_id)) with check (puede_ver(usuario_id));

-- Comentarios: los ve quien ve al cliente; los escribe y edita su autor
-- (mientras siga viendo al cliente); no se borran.
create policy "ver comentarios" on comentarios for select to authenticated
  using (puede_ver_cliente(cliente_id));
create policy "escribir comentarios" on comentarios for insert to authenticated
  with check (autor_id = auth.uid() and puede_ver_cliente(cliente_id));
create policy "editar mis comentarios" on comentarios for update to authenticated
  using (autor_id = auth.uid() and puede_ver_cliente(cliente_id))
  with check (autor_id = auth.uid());

-- Historial de ediciones: lo ve quien ve el comentario; lo escribe el trigger.
create policy "ver ediciones" on comentarios_ediciones for select to authenticated
  using (exists (select 1 from comentarios c
                 where c.id = comentario_id and puede_ver_cliente(c.cliente_id)));

-- Solicitudes de precio: las ve quien la pidió y sus superiores; las crea el
-- vendedor para un cliente suyo. Responder: función responder_solicitud (fase 5).
create policy "ver solicitudes" on solicitudes_precio for select to authenticated
  using (puede_ver(solicitante_id));
create policy "pedir autorizacion" on solicitudes_precio for insert to authenticated
  with check (
    solicitante_id = auth.uid()
    and estado = 'pendiente'
    and puede_ver_cliente(cliente_id)
    and sucursal_id = mi_sucursal()
    and jefe_id = (select jefe_id from sucursales where id = mi_sucursal())
  );

-- Ventas y todo lo que cuelga de ellas: solo lectura desde la app.
-- Se escriben con registrar_venta / registrar_abono / anular_venta (fase 5).
create policy "ver ventas" on ventas for select to authenticated
  using (puede_ver(vendedor_id));
create policy "ver lineas de venta" on venta_lineas for select to authenticated
  using (puede_ver_venta(venta_id));
create policy "ver cuotas" on cuotas for select to authenticated
  using (puede_ver_venta(venta_id));
create policy "ver pagos" on pagos for select to authenticated
  using (puede_ver_venta(venta_id));

-- Metas: las ve quien ve la sucursal (y cada vendedor la de la suya);
-- las fija el gerente general.
create policy "ver metas" on metas for select to authenticated
  using (sucursal_id = mi_sucursal() or puede_ver_sucursal(sucursal_id));
create policy "gerente fija metas" on metas for insert to authenticated
  with check (mi_rol() = 'gerente_general' and fijada_por = auth.uid());
create policy "gerente corrige metas" on metas for update to authenticated
  using (mi_rol() = 'gerente_general');

-- Cierres: se ven como las metas; se crean con cerrar_mes (fase 7).
create policy "ver cierres" on cierres_mensuales for select to authenticated
  using (sucursal_id = mi_sucursal() or puede_ver_sucursal(sucursal_id));


-- -----------------------------------------------------------------------------
-- 11. Datos iniciales
-- -----------------------------------------------------------------------------

insert into metodos_pago (codigo, nombre, es_credito) values
  ('credito',    'Crédito',    true),
  ('efectivo',   'Efectivo',   false),
  ('tarjeta',    'Tarjeta',    false),
  ('visacuotas', 'Visacuotas', false);

-- La instalación es un servicio sin precio fijo (siempre pasa por el jefe).
insert into productos (codigo, nombre, tipo, categoria, descripcion) values
  ('INST', 'Instalación', 'servicio', 'Servicios',
   'Precio según el caso (estructura, nivelación, etc.). Requiere visto bueno del jefe.');

-- La sucursal y el perfil de Fredy se crean a mano en el panel de Supabase
-- (o con la Edge Function crear_usuario), porque dependen de su usuario en auth.users.
