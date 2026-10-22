\set ON_ERROR_STOP 0
-- Datos de prueba (como superusuario, igual que el panel de Supabase)
insert into auth.users (id,email) values
 ('00000000-0000-0000-0000-00000000000a','gerente@x'),
 ('00000000-0000-0000-0000-00000000000b','super@x'),
 ('00000000-0000-0000-0000-00000000000f','fredy@x'),
 ('00000000-0000-0000-0000-000000000001','v1@x'),
 ('00000000-0000-0000-0000-000000000002','j2@x'),
 ('00000000-0000-0000-0000-000000000003','v3@x');
insert into sucursales (id,codigo,nombre) values
 ('10000000-0000-0000-0000-000000000001','S01','Sucursal Fredy'),
 ('10000000-0000-0000-0000-000000000002','S02','Sucursal 2');
insert into perfiles (id,nombre,rol,sucursal_id) values
 ('00000000-0000-0000-0000-00000000000a','Gerente','gerente_general',null),
 ('00000000-0000-0000-0000-00000000000b','Supervisor','supervisor',null),
 ('00000000-0000-0000-0000-00000000000f','Fredy','jefe_sucursal','10000000-0000-0000-0000-000000000001'),
 ('00000000-0000-0000-0000-000000000001','Vendedor 1','vendedor','10000000-0000-0000-0000-000000000001'),
 ('00000000-0000-0000-0000-000000000002','Jefe 2','jefe_sucursal','10000000-0000-0000-0000-000000000002'),
 ('00000000-0000-0000-0000-000000000003','Vendedor 3','vendedor','10000000-0000-0000-0000-000000000002');
update sucursales set jefe_id='00000000-0000-0000-0000-00000000000f', supervisor_id='00000000-0000-0000-0000-00000000000b' where codigo='S01';
update sucursales set jefe_id='00000000-0000-0000-0000-000000000002', supervisor_id='00000000-0000-0000-0000-00000000000b' where codigo='S02';
\echo '--- check rol/sucursal (debe fallar):'
insert into perfiles (id,nombre,rol,sucursal_id) values ('00000000-0000-0000-0000-00000000000a','x','vendedor',null);
insert into clientes (id,vendedor_id,nombre,telefono,creado_por) values
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','Cliente de V1','5555','00000000-0000-0000-0000-000000000001'),
 ('20000000-0000-0000-0000-00000000000f','00000000-0000-0000-0000-00000000000f','Cliente de Fredy','5556','00000000-0000-0000-0000-00000000000f'),
 ('20000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003','Cliente de V3','5557','00000000-0000-0000-0000-000000000003');
insert into productos (id,nombre,precio_lista) values ('30000000-0000-0000-0000-000000000001','Calentador 200L',4900);
\echo '--- producto sin precio (debe fallar):'
insert into productos (nombre) values ('Panel sin precio');

-- llamadas: contestó (interesado), luego 3 sin respuesta
insert into actividades (cliente_id,usuario_id,tipo,estado,resultado,realizada_en,creado_por) values
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','llamada','completada','interesado', now()-interval '10 day','00000000-0000-0000-0000-000000000001'),
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','llamada','completada','no_contesto', now()-interval '3 day','00000000-0000-0000-0000-000000000001'),
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','llamada','completada','no_contesto', now()-interval '2 day','00000000-0000-0000-0000-000000000001'),
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','llamada','completada','no_contesto', now()-interval '1 day','00000000-0000-0000-0000-000000000001');
insert into actividades (cliente_id,usuario_id,tipo,programada_para,creado_por) values
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','llamada', now()+interval '1 day','00000000-0000-0000-0000-000000000001');
\echo '--- resultado en pendiente (debe fallar):'
insert into actividades (cliente_id,usuario_id,tipo,resultado,creado_por) values ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','llamada','no_contesto','00000000-0000-0000-0000-000000000001');

\echo '--- numero de venta:'
select siguiente_numero_venta('10000000-0000-0000-0000-000000000001'), siguiente_numero_venta('10000000-0000-0000-0000-000000000001');

-- Probar RLS con cada usuario
create function pg_temp.como(u text) returns void language plpgsql as $$
begin perform set_config('request.jwt.claim.sub', u, false); end $$;

set role authenticated;
\echo '=== V1: debe ver solo su cliente (1) y su perfil'
select pg_temp.como('00000000-0000-0000-0000-000000000001');
select nombre from clientes order by nombre;
select nombre from perfiles order by nombre;
select nombre, no_contesto, intentos_sin_respuesta, proxima_llamada is not null as tiene_proxima from clientes_resumen;
\echo '--- V1 crea cliente para V3 (debe fallar):'
insert into clientes (vendedor_id,nombre,telefono,creado_por) values ('00000000-0000-0000-0000-000000000003','X','1','00000000-0000-0000-0000-000000000001');
\echo '--- V1 crea cliente propio (ok):'
insert into clientes (vendedor_id,nombre,telefono,creado_por) values ('00000000-0000-0000-0000-000000000001','Nuevo de V1','1','00000000-0000-0000-0000-000000000001');
\echo '--- V1 edita producto (0 filas):'
update productos set precio_lista=1 where id='30000000-0000-0000-0000-000000000001';
\echo '--- V1 inserta venta directo (debe fallar):'
insert into ventas (numero,sucursal_id,cliente_id,vendedor_id,total,registrada_por) values ('S01-X','10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001',1,'00000000-0000-0000-0000-000000000001');
\echo '--- V1 comenta y edita su comentario (ok, queda el texto anterior):'
insert into comentarios (cliente_id,autor_id,texto) values ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','Llamar después de las 4');
update comentarios set texto='Llamar después de las 5';
select texto, editado_en is not null as editado from comentarios;
select texto_anterior from comentarios_ediciones;
\echo '--- V1 intenta mover su comentario a otro cliente (debe fallar):'
update comentarios set cliente_id='20000000-0000-0000-0000-00000000000f';
\echo '--- V1 pide autorización al jefe correcto (ok) y a otro jefe (falla):'
insert into solicitudes_precio (tipo,sucursal_id,cliente_id,producto_id,solicitante_id,jefe_id,precio_solicitado,motivo) values ('descuento','10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000000f',4100,'cliente fiel');
insert into solicitudes_precio (tipo,sucursal_id,cliente_id,producto_id,solicitante_id,jefe_id,precio_solicitado,motivo) values ('descuento','10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002',4100,'x');
\echo '--- V1 aprueba su propia solicitud (0 filas):'
update solicitudes_precio set estado='aprobada';

\echo '=== Fredy: ve sus clientes y los de V1, no los de V3'
select pg_temp.como('00000000-0000-0000-0000-00000000000f');
select nombre from clientes order by nombre;
select count(*) as solicitudes_que_ve from solicitudes_precio;
\echo '--- Fredy intenta editar el comentario de V1 (0 filas) pero sí lo ve con su historial:'
update comentarios set texto='otro';
select count(*) as comentarios, (select count(*) from comentarios_ediciones) as ediciones from comentarios;
\echo '--- Fredy cambia precio (ok) -> bitacora:'
update productos set precio_lista=4950 where id='30000000-0000-0000-0000-000000000001';
select campo, valor_anterior, valor_nuevo, cambiado_por is not null as con_autor from productos_bitacora;
\echo '--- Fredy fija hasta en (debe fallar, solo gerente):'
insert into precios_hasta_en (producto_id,precio_minimo,vigente_desde,vigente_hasta,fijado_por) values ('30000000-0000-0000-0000-000000000001',4200,'2026-11-01','2026-11-30','00000000-0000-0000-0000-00000000000f');

\echo '=== Supervisor: ve todo (4 clientes)'
select pg_temp.como('00000000-0000-0000-0000-00000000000b');
select count(*) from clientes;

\echo '=== Gerente: hasta en y traslape'
select pg_temp.como('00000000-0000-0000-0000-00000000000a');
select count(*) as clientes from clientes;
insert into precios_hasta_en (producto_id,precio_minimo,vigente_desde,vigente_hasta,fijado_por) values ('30000000-0000-0000-0000-000000000001',4200,'2026-11-01','2026-11-30','00000000-0000-0000-0000-00000000000a');
\echo '--- traslape (debe fallar):'
insert into precios_hasta_en (producto_id,precio_minimo,vigente_desde,vigente_hasta,fijado_por) values ('30000000-0000-0000-0000-000000000001',4000,'2026-11-15','2026-12-15','00000000-0000-0000-0000-00000000000a');

\echo '=== V3 (otra sucursal): no ve nada de S01'
select pg_temp.como('00000000-0000-0000-0000-000000000003');
select nombre from clientes;
select count(*) as metas from metas;

\echo '=== anon: nada'
reset role; set role anon;
select count(*) from clientes;
reset role;

\echo '=== Ventas, cuotas, cierre de mes (como superusuario, igual que lo hará registrar_venta)'
insert into ventas (id,numero,sucursal_id,cliente_id,vendedor_id,fecha,total,numero_cuotas,registrada_por) values ('40000000-0000-0000-0000-000000000001','S01-000003','10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','2026-09-15',12000,12,'00000000-0000-0000-0000-000000000001');
insert into cuotas (id,venta_id,numero,monto,vence_el) values ('50000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001',1,1000,'2026-09-30'),('50000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000001',2,1000,'2026-10-15');
insert into pagos (venta_id,cuota_id,metodo_pago_id,monto,fecha_pago,registrado_por) select '40000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',id,1000,'2026-09-29','00000000-0000-0000-0000-000000000001' from metodos_pago where codigo='credito';
insert into venta_lineas (venta_id,producto_id,cantidad,precio_lista,precio_unitario) values ('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',2,4900,4500);
select subtotal from venta_lineas;
select numero, pagado, saldo, pagada, atrasada from cuotas_estado order by numero;
insert into cierres_mensuales (sucursal_id,mes,total_cobrado,total_vendido,numero_ventas,cerrado_por) values ('10000000-0000-0000-0000-000000000001','2026-09-01',1000,12000,1,'00000000-0000-0000-0000-00000000000f');
\echo '--- pago en septiembre cerrado (debe fallar):'
insert into pagos (venta_id,metodo_pago_id,monto,fecha_pago,registrado_por) select '40000000-0000-0000-0000-000000000001',id,50,'2026-09-30 20:00-06','00000000-0000-0000-0000-000000000001' from metodos_pago where codigo='efectivo';
\echo '--- anular venta de mes cerrado (debe fallar):'
update ventas set estado='anulada', anulada_en=now(), motivo_anulacion='x';
\echo '--- pago en octubre (ok):'
insert into pagos (venta_id,cuota_id,metodo_pago_id,monto,fecha_pago,registrado_por) select '40000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000002',id,1000,'2026-10-14','00000000-0000-0000-0000-000000000001' from metodos_pago where codigo='credito';
\echo '=== V1 ve su venta y pagos; V3 no'
set role authenticated;
select pg_temp.como('00000000-0000-0000-0000-000000000001');
select (select count(*) from ventas) v, (select count(*) from pagos) p, (select count(*) from cuotas_estado) q;
select pg_temp.como('00000000-0000-0000-0000-000000000003');
select (select count(*) from ventas) v, (select count(*) from pagos) p;
