create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  expert_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('text','voice','video')),
  scheduled_at timestamptz not null,
  duration_min int not null default 20,
  status text not null check (status in ('booked','completed','canceled')) default 'booked',
  paid_amount numeric(10,2),
  paid_via text,
  notes text,
  created_at timestamptz not null default now()
);

alter table public.appointments enable row level security;

create policy "User can read own appts"
on public.appointments
for select
using (auth.uid() = user_id or auth.uid() = expert_id);

create policy "User can create own appt"
on public.appointments
for insert
with check (auth.uid() = user_id);

create policy "User/Expert can update their appt"
on public.appointments
for update
using (auth.uid() = user_id or auth.uid() = expert_id)
with check (auth.uid() = user_id or auth.uid() = expert_id);

create policy "Admin can manage all appts"
on public.appointments
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create index if not exists idx_appts_user on public.appointments(user_id);
create index if not exists idx_appts_expert on public.appointments(expert_id);
create index if not exists idx_appts_time on public.appointments(scheduled_at);
