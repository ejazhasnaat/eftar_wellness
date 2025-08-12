-- Insert admin profile for an existing user
insert into public.profiles (id, full_name, role, city, country)
values (
  '74e649a4-0b51-439e-bc95-c050297f2902',           -- your user UUID from auth.users
  'App Owner',
  'admin',
  'Lahore',
  'Pakistan'
)
on conflict (id) do update
set role = 'admin';
