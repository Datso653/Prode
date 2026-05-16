-- ============================================================
-- PRODE SOLIDARIO 2026 - Setup de Supabase
-- ============================================================
-- Ejecutar en: Supabase Dashboard > SQL Editor > New Query > Run
-- ============================================================

-- ============================================================
-- 1. TABLA DE INSCRIPCIONES
-- ============================================================
create table if not exists public.inscripciones (
  id              uuid primary key default gen_random_uuid(),
  ticket          text unique not null default upper(substring(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
  nombre          text not null,
  apellido        text not null,
  email           text not null,
  whatsapp        text not null,
  dni             text,
  monto           integer not null,                     -- en pesos, ej: 20000
  comprobante_url text,                                  -- ruta al archivo en Storage
  estado          text not null default 'pendiente',     -- pendiente | confirmado | rechazado
  notas_admin     text,                                  -- notas internas opcionales
  created_at      timestamptz default now(),
  confirmed_at    timestamptz,

  -- Validaciones
  constraint nombre_no_vacio   check (char_length(trim(nombre)) >= 2),
  constraint apellido_no_vacio check (char_length(trim(apellido)) >= 2),
  constraint email_valido      check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  constraint estado_valido     check (estado in ('pendiente','confirmado','rechazado')),
  constraint email_unico       unique (email)
);

create index if not exists inscripciones_estado_idx  on public.inscripciones (estado);
create index if not exists inscripciones_created_idx on public.inscripciones (created_at desc);

-- ============================================================
-- 2. ROW LEVEL SECURITY - tabla
-- ============================================================
alter table public.inscripciones enable row level security;

-- INSERT: cualquiera puede inscribirse desde el form (validamos que no puedan
-- auto-confirmarse ni meter notas de admin)
drop policy if exists "inscripcion_publica" on public.inscripciones;
create policy "inscripcion_publica"
  on public.inscripciones for insert to anon
  with check (
    estado = 'pendiente'
    and notas_admin is null
    and confirmed_at is null
  );

-- SELECT: nadie puede leer desde el front. Todo se gestiona desde
-- el dashboard de Supabase (Table Editor) o un backend con service_role.

-- ============================================================
-- 3. STORAGE BUCKET para comprobantes
-- ============================================================
insert into storage.buckets (id, name, public)
values ('comprobantes', 'comprobantes', false)
on conflict (id) do nothing;

-- UPLOAD: anónimos pueden subir, solo a la carpeta 'pagos/'
drop policy if exists "subir_comprobante" on storage.objects;
create policy "subir_comprobante"
  on storage.objects for insert to anon
  with check (
    bucket_id = 'comprobantes'
    and (storage.foldername(name))[1] = 'pagos'
  );

-- READ: nadie desde el front. Los ves desde Supabase > Storage.

-- ============================================================
-- 4. VISTA OPCIONAL: resumen ordenado para revisión
-- ============================================================
create or replace view public.vw_inscripciones_resumen as
select
  ticket,
  nombre || ' ' || apellido as nombre_completo,
  email,
  whatsapp,
  monto,
  estado,
  comprobante_url,
  created_at,
  confirmed_at
from public.inscripciones
order by created_at desc;

-- ============================================================
-- LISTO. Pasos siguientes:
--   1. Project Settings > API → copiá URL y anon key → pegá en index.html
--   2. Editá los datos de pago (alias/CBU) en index.html
--   3. Para ver inscripciones: Table Editor > inscripciones
--   4. Para ver comprobantes:  Storage > comprobantes > pagos/
--   5. Para confirmar un pago: editás 'estado' a 'confirmado' en el row
-- ============================================================
