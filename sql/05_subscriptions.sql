-- PLANS
create table if not exists public.plans (
  id text primary key,                 -- 'monthly', 'yearly', etc.
  title text not null,
  price_cents int not null,
  currency text not null default 'usd',
  features jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- SUBSCRIPTIONS
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_id text not null references public.plans(id),
  start_date date not null default (now()::date),
  end_date date,
  status text not null check (status in ('active','past_due','canceled')) default 'active',
  payment_provider text,                -- 'stripe', 'razorpay', etc.
  provider_subscription_id text,
  created_at timestamptz not null default now()
);

alter table public.subscriptions enable row level security;

-- 🔧 Drop policies if they already exist (prevents name collisions)
drop policy if exists "Owner can read own subscriptions" on public.subscriptions;
drop policy if exists "Owner can modify own subscriptions (client-side safety)" on public.subscriptions;
drop policy if exists "Admin can manage subscriptions" on public.subscriptions;

-- ✅ Recreate policies
create policy "Owner can read own subscriptions"
on public.subscriptions
for select
using (auth.uid() = user_id);

create policy "Owner can modify own subscriptions (client-side safety)"
on public.subscriptions
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Admin can manage subscriptions"
on public.subscriptions
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- Indexes
create index if not exists idx_subscriptions_user on public.subscriptions(user_id);
create index if not exists idx_subscriptions_status on public.subscriptions(status);

