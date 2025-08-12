create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  image_url text,
  items_detected jsonb not null default '[]'::jsonb,
  calories numeric(10,2),
  protein numeric(10,2),
  carbs numeric(10,2),
  fats numeric(10,2),
  confidence numeric(5,2),
  logged_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.meals enable row level security;

create policy "Owner can read meals"
on public.meals
for select
using (auth.uid() = user_id);

create policy "Owner can insert/update meals"
on public.meals
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Admin can manage all meals"
on public.meals
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create index if not exists idx_meals_user on public.meals(user_id);
create index if not exists idx_meals_logged_at on public.meals(logged_at);
