-- =========================================
-- CLEAN BASELINE SCHEMA (REPLACE EXISTING)
-- Roles, Approvals, Admin-only Products
-- =========================================

-- Enable UUID generator
create extension if not exists pgcrypto;

-- ---------- DROP OLD TABLES (safe if none exist) ----------
drop table if exists public.products cascade;
drop table if exists public.vendors cascade;         -- deprecated, removed
drop table if exists public.food_providers cascade;
drop table if exists public.experts cascade;
drop table if exists public.profiles cascade;

-- ---------- PROFILES ----------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null check (role in ('health_seeker','dietitian','fitness_expert','provider','admin')) default 'health_seeker',
  city text,
  country text,
  created_at timestamptz not null default now()
);

-- RLS
alter table public.profiles enable row level security;

create policy "Profiles are viewable by owner"
on public.profiles
for select
using (auth.uid() = id);

create policy "Users can insert their own profile"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "Users can update own profile"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- Helpful index
create index idx_profiles_role on public.profiles(role);

-- ---------- EXPERTS ----------
create table public.experts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  bio text,
  expertise_tags jsonb not null default '[]'::jsonb,
  experience_years int not null default 0,
  availability jsonb not null default '[]'::jsonb,
  rate_per_appointment numeric(10,2),
  status text not null check (status in ('active','in_meeting','unavailable')) default 'active',
  expert_type text check (expert_type in ('dietitian','fitness_expert')),
  approval_status text not null check (approval_status in ('pending','approved','rejected')) default 'pending',
  city text,
  country text,
  created_at timestamptz not null default now()
);

-- RLS
alter table public.experts enable row level security;

create policy "Expert can manage own expert row"
on public.experts
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Helpful indexes
create index idx_experts_user_id on public.experts(user_id);
create index idx_experts_approval on public.experts(approval_status);
create index idx_experts_type on public.experts(expert_type);

-- ---------- FOOD PROVIDERS ----------
create table public.food_providers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text,
  delivery_range_km int not null default 5,
  menu jsonb not null default '[]'::jsonb,
  rating numeric(3,2),
  city text,
  country text,
  status text not null check (status in ('active','unavailable')) default 'active',
  approval_status text not null check (approval_status in ('pending','approved','rejected')) default 'pending',
  created_at timestamptz not null default now()
);

-- RLS
alter table public.food_providers enable row level security;

create policy "Provider can manage own row"
on public.food_providers
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Helpful indexes
create index idx_food_providers_user_id on public.food_providers(user_id);
create index idx_food_providers_approval on public.food_providers(approval_status);

-- ---------- ADMIN-ONLY PRODUCTS (viewable by all) ----------

-- helper: check if a user is admin (profiles.role = 'admin')
create or replace function public.is_admin(uid uuid)
returns boolean
language sql
stable
as $$
  select exists(
    select 1 from public.profiles p
    where p.id = uid and p.role = 'admin'
  );
$$;

create table public.products (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text,
  price numeric(12,2) not null default 0,
  inventory_count int not null default 0,
  images jsonb not null default '[]'::jsonb,
  is_visible boolean not null default true,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- updated_at trigger
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end$$;

drop trigger if exists trg_products_set_updated_at on public.products;
create trigger trg_products_set_updated_at
before update on public.products
for each row execute procedure public.set_updated_at();

-- RLS: everyone can SELECT; only admins can write
alter table public.products enable row level security;

drop policy if exists "Products are viewable by all" on public.products;
create policy "Products are viewable by all"
on public.products
for select
using (true);

drop policy if exists "Only admins can insert products" on public.products;
create policy "Only admins can insert products"
on public.products
for insert
with check (public.is_admin(auth.uid()));

drop policy if exists "Only admins can update products" on public.products;
create policy "Only admins can update products"
on public.products
for update
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists "Only admins can delete products" on public.products;
create policy "Only admins can delete products"
on public.products
for delete
using (public.is_admin(auth.uid()));

-- Helpful indexes
create index idx_products_visible on public.products(is_visible);
create index idx_products_category on public.products(category);

-- =========================================
-- END BASELINE
-- =========================================

