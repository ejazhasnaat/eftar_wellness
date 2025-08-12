-- =========================================
-- 02_functions_is_premium_and_counters.sql
-- Idempotent: does NOT touch subscriptions policies
-- =========================================

-- 1) Drop & recreate is_premium AFTER subscriptions table exists
-- (Safe to run multiple times)
drop function if exists public.is_premium(uuid);

create or replace function public.is_premium(uid uuid)
returns boolean
language sql
stable
as $$
  select exists(
    select 1
    from public.subscriptions s
    where s.user_id = uid
      and s.status = 'active'
      and coalesce(s.end_date, now()) >= now()
  );
$$;

-- 2) Create usage_counters if missing
create table if not exists public.usage_counters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('assistant_turn','free_appointment')),
  period_start date not null,
  count int not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, kind, period_start)
);

alter table public.usage_counters enable row level security;

-- Replace policies cleanly (prevents name collisions)
drop policy if exists "Owner can read/write own counters" on public.usage_counters;
drop policy if exists "Admin can manage counters" on public.usage_counters;

create policy "Owner can read/write own counters"
on public.usage_counters
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Admin can manage counters"
on public.usage_counters
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- 3) Convenience view for current month usage
create or replace view public.v_usage_this_month as
select user_id, kind, count
from public.usage_counters
where date_trunc('month', period_start) = date_trunc('month', now());

