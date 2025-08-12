create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  goal_type text not null check (goal_type in ('weight_loss','weight_gain','stay_fit')),
  duration_days int not null check (duration_days between 7 and 120),
  price numeric(10,2),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.challenges enable row level security;

create policy "Anyone can view active challenges"
on public.challenges
for select
using (is_active = true or public.is_admin(auth.uid()));

create policy "Admin can manage challenges"
on public.challenges
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create table if not exists public.challenge_participants (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  unique (challenge_id, user_id)
);

alter table public.challenge_participants enable row level security;

create policy "User can manage own participation"
on public.challenge_participants
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Admin can manage all participants"
on public.challenge_participants
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create table if not exists public.challenge_checkins (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  checkin_date date not null,
  notes text,
  unique (challenge_id, user_id, checkin_date)
);

alter table public.challenge_checkins enable row level security;

create policy "User can manage own check-ins"
on public.challenge_checkins
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Admin can manage all check-ins"
on public.challenge_checkins
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create or replace view public.v_challenge_leaderboard as
with streaks as (
  select
    cp.challenge_id,
    cp.user_id,
    max(cc.checkin_date) as last_checkin,
    count(*) as total_checkins
  from public.challenge_participants cp
  left join public.challenge_checkins cc
    on cc.challenge_id = cp.challenge_id and cc.user_id = cp.user_id
  group by cp.challenge_id, cp.user_id
)
select
  c.id as challenge_id,
  s.user_id,
  s.total_checkins,
  rank() over (partition by c.id order by s.total_checkins desc) as rnk
from public.challenges c
join streaks s on s.challenge_id = c.id;
