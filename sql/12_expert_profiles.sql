-- 12_expert_profiles.sql (idempotent)
-- Expert profiles table + RLS + hardening + safe re-runs.

-- 1) Helper: is_admin() (idempotent)
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

-- 2) Table
create table if not exists public.expert_profiles (
  user_id uuid primary key
    references auth.users (id) on delete cascade,

  specialization text check (specialization in ('dietitian','fitnessExpert')),
  portfolio_url text,
  linkedin_url text,
  license_no text,
  years_experience int check (years_experience is null or years_experience >= 0),
  primary_specialty text,
  notes text,

  status text not null default 'pending'
    check (status in ('pending','approved','rejected')),

  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewer_id uuid references auth.users (id)
);

alter table public.expert_profiles enable row level security;

-- 3) RLS Policies (idempotent: catch duplicate_object)

do $$
begin
  create policy "expert_profiles_select_own"
  on public.expert_profiles
  for select
  to authenticated
  using (user_id = auth.uid());
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create policy "expert_profiles_insert_self"
  on public.expert_profiles
  for insert
  to authenticated
  with check (user_id = auth.uid());
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create policy "expert_profiles_update_own"
  on public.expert_profiles
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create policy "expert_profiles_admin_read"
  on public.expert_profiles
  for select
  to authenticated
  using (public.is_admin());
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create policy "expert_profiles_admin_write"
  on public.expert_profiles
  for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());
exception
  when duplicate_object then null;
end $$;

-- 4) Trigger + guard function (idempotent for function; trigger dropped/created)

create or replace function public.enforce_expert_profiles_update_guard()
returns trigger
language plpgsql
security definer
as $$
begin
  if not public.is_admin() then
    -- Hardening: once approved, owners cannot edit anything.
    if (old.status = 'approved') then
      raise exception 'Approved expert profiles cannot be edited by owner';
    end if;

    -- Guard admin-controlled fields even before approval.
    if (new.status is distinct from old.status)
       or (new.reviewed_at is distinct from old.reviewed_at)
       or (new.reviewer_id is distinct from old.reviewer_id) then
      raise exception 'Only admins can change status/review fields';
    end if;

    -- Ensure user_id is immutable.
    if (new.user_id is distinct from old.user_id) then
      raise exception 'user_id cannot be changed';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_expert_profiles_guard on public.expert_profiles;

create trigger trg_expert_profiles_guard
before update on public.expert_profiles
for each row execute function public.enforce_expert_profiles_update_guard();

-- 5) Helpful index for admin review queries (idempotent)
create index if not exists idx_expert_profiles_status_submitted_at
  on public.expert_profiles (status, submitted_at desc);

