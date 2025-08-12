-- Bucket (safe if run multiple times)
insert into storage.buckets (id, name, public)
values ('meal-photos','meal-photos', false)
on conflict (id) do nothing;

-- Clean up any same‑name policies from previous attempts
drop policy if exists "Users can upload their own meal photos" on storage.objects;
drop policy if exists "Users can view their own meal photos" on storage.objects;
drop policy if exists "Users can update/delete own meal photos" on storage.objects;
drop policy if exists "Admins can manage all meal photos" on storage.objects;

-- Create fresh policies scoped to the meal-photos bucket
create policy "Users can upload their own meal photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'meal-photos'
  and auth.uid() = owner
);

create policy "Users can view their own meal photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'meal-photos'
  and auth.uid() = owner
);

create policy "Users can update/delete own meal photos"
on storage.objects
for update
to authenticated
using (bucket_id = 'meal-photos' and auth.uid() = owner)
with check (bucket_id = 'meal-photos' and auth.uid() = owner);

create policy "Admins can manage all meal photos"
on storage.objects
for all
to authenticated
using (bucket_id = 'meal-photos' and public.is_admin(auth.uid()))
with check (bucket_id = 'meal-photos' and public.is_admin(auth.uid()));

