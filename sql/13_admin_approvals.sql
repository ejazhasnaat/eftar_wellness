-- 13_admin_approvals.sql (idempotent)
-- Admin-side helpers to approve/reject expert profiles with auditing.

-- 0) Safety: ensure is_admin() exists (harmless if already present)
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

-- 1) Audit table: expert_profile_reviews
create table if not exists public.expert_profile_reviews (
  id bigserial primary key,
  user_id uuid not null
    references public.expert_profiles (user_id) on delete cascade,
  old_status text check (old_status in ('pending','approved','rejected')),
  new_status text not null check (new_status in ('pending','approved','rejected')),
  reviewer_id uuid not null references auth.users (id),
  reviewer_notes text,
  reviewed_at timestamptz not null default now()
);

alter table public.expert_profile_reviews enable row level security;

-- Policies (idempotent)
do $$
begin
  create policy "reviews_admin_read"
  on public.expert_profile_reviews
  for select
  to authenticated
  using (public.is_admin());
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create policy "reviews_reviewer_own_read"
  on public.expert_profile_reviews
  for select
  to authenticated
  using (reviewer_id = auth.uid());
exception
  when duplicate_object then null;
end $$;

-- Helpful index for admin queries
create index if not exists idx_reviews_user_status_time
  on public.expert_profile_reviews (user_id, new_status, reviewed_at desc);

-- 2) RPC: review_expert_profile(user_id, new_status, reviewer_notes)
-- - Only admins can call (checked inside)
-- - Upserts expert_profiles if missing, sets status/review fields
-- - Writes audit row
-- - Returns the updated expert_profiles row
create or replace function public.review_expert_profile(
  p_user_id uuid,
  p_new_status text,
  p_reviewer_notes text default null
)
returns public.expert_profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_old public.expert_profiles;
  v_new public.expert_profiles;
begin
  if not public.is_admin() then
    raise exception 'Only admins can review expert profiles';
  end if;

  if p_new_status not in ('approved','rejected','pending') then
    raise exception 'Invalid status. Must be approved/rejected/pending';
  end if;

  -- Load or create stub
  select * into v_old
  from public.expert_profiles
  where user_id = p_user_id;

  if not found then
    insert into public.expert_profiles(user_id, status)
    values (p_user_id, 'pending')
    on conflict (user_id) do nothing;

    select * into v_old
    from public.expert_profiles
    where user_id = p_user_id;
  end if;

  -- Update status + review metadata
  update public.expert_profiles
     set status = p_new_status,
         reviewed_at = now(),
         reviewer_id = auth.uid()
   where user_id = p_user_id
  returning * into v_new;

  -- Audit trail
  insert into public.expert_profile_reviews(
    user_id, old_status, new_status, reviewer_id, reviewer_notes
  ) values (
    p_user_id, v_old.status, v_new.status, auth.uid(), p_reviewer_notes
  );

  return v_new;
end;
$$;

-- 3) Grants (idempotent/harmless if repeated)
revoke all on function public.review_expert_profile(uuid, text, text) from public;
grant execute on function public.review_expert_profile(uuid, text, text) to authenticated;

