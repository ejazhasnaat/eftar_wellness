create table if not exists public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null references auth.users(id) on delete restrict,
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.admin_audit_logs enable row level security;

create policy "Admins read/write"
on public.admin_audit_logs
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));
