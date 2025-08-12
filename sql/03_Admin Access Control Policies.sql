-- Admin can manage experts
drop policy if exists "Admin can manage experts" on public.experts;
create policy "Admin can manage experts"
on public.experts
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- Admin can manage food providers
drop policy if exists "Admin can manage providers" on public.food_providers;
create policy "Admin can manage providers"
on public.food_providers
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));
