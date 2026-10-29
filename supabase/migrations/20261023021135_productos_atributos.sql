-- =============================================================================
-- Kusdy · Migración 3: atributos reales de productos (2026-10-23)
-- =============================================================================
-- Aplicada en kusdy-dev con la versión 20261023021135 (el nombre del archivo
-- coincide con ella). Sale de la lista de precios de Energica Solar (mayo 2026).
-- Aditiva: solo agrega columnas opcionales; los servicios (Instalación) las dejan vacías.
-- =============================================================================

alter table productos
  add column capacidad_litros integer check (capacidad_litros > 0),
  add column personas         text,   -- texto de la lista, ej. '3-4'
  add column medidas          text;   -- ej. '1.27 x 2.00 m'
