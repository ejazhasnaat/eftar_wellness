-- =========================================
-- 04_messaging.sql  (idempotent)
-- Conversations + Messages with RLS
-- Uses '= ANY(participants)' to avoid uuid = uuid[] errors
-- =========================================

create extension if not exists pgcrypto;

-- updated_at helper
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end$$;

-- =========================================
-- Conversations
-- =========================================
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  participants uuid[] not null,                      -- array of auth.users.id
  last_message text,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint participants_nonempty check (array_length(participants, 1) >= 1)
);

-- Indexes
create index if not exists idx_conversations_last_msg_at on public.conversations(last_message_at desc);
create index if not exists idx_conversations_updated_at on public.conversations(updated_at desc);
create index if not exists idx_conversations_participants_gin on public.conversations using gin (participants);

-- Trigger
drop trigger if exists trg_conversations_set_updated_at on public.conversations;
create trigger trg_conversations_set_updated_at
before update on public.conversations
for each row execute procedure public.set_updated_at();

-- RLS
alter table public.conversations enable row level security;

drop policy if exists "Users can view their own conversations" on public.conversations;
drop policy if exists "Users can create conversations they participate in" on public.conversations;
drop policy if exists "Users can update conversations they participate in" on public.conversations;
drop policy if exists "Admin can manage all conversations" on public.conversations;

create policy "Users can view their own conversations"
on public.conversations
for select
using ( auth.uid() = ANY(participants) );

create policy "Users can create conversations they participate in"
on public.conversations
for insert
with check ( auth.uid() = ANY(participants) );

create policy "Users can update conversations they participate in"
on public.conversations
for update
using ( auth.uid() = ANY(participants) )
with check ( auth.uid() = ANY(participants) );

create policy "Admin can manage all conversations"
on public.conversations
for all
using ( public.is_admin(auth.uid()) )
with check ( public.is_admin(auth.uid()) );

-- =========================================
-- Messages
-- =========================================
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  body text,
  attachments jsonb not null default '[]'::jsonb,   -- [{type,url,meta}]
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_messages_conversation_created_at on public.messages(conversation_id, created_at);
create index if not exists idx_messages_sender on public.messages(sender_id);

-- Trigger
drop trigger if exists trg_messages_set_updated_at on public.messages;
create trigger trg_messages_set_updated_at
before update on public.messages
for each row execute procedure public.set_updated_at();

-- Keep conversation last_message fresh
create or replace function public.bump_conversation_last_message()
returns trigger language plpgsql as $$
begin
  update public.conversations
  set last_message = coalesce(new.body, '[attachment]'),
      last_message_at = new.created_at,
      updated_at = now()
  where id = new.conversation_id;
  return new;
end$$;

drop trigger if exists trg_messages_bump_conversation on public.messages;
create trigger trg_messages_bump_conversation
after insert on public.messages
for each row execute procedure public.bump_conversation_last_message();

-- RLS
alter table public.messages enable row level security;

drop policy if exists "Participants can read messages" on public.messages;
drop policy if exists "Sender can insert messages" on public.messages;
drop policy if exists "Participants can update messages (e.g., mark read)" on public.messages;
drop policy if exists "Admin can manage all messages" on public.messages;

-- Read: any participant in the conversation
create policy "Participants can read messages"
on public.messages
for select
using (
  exists (
    select 1
    from public.conversations c
    where c.id = public.messages.conversation_id
      and auth.uid() = ANY(c.participants)
  )
);

-- Insert: sender must be current user AND a participant
create policy "Sender can insert messages"
on public.messages
for insert
with check (
  sender_id = auth.uid()
  and exists (
    select 1
    from public.conversations c
    where c.id = conversation_id
      and auth.uid() = ANY(c.participants)
  )
);

-- Update: allow participants to update (e.g., mark read)
create policy "Participants can update messages (e.g., mark read)"
on public.messages
for update
using (
  exists (
    select 1
    from public.conversations c
    where c.id = public.messages.conversation_id
      and auth.uid() = ANY(c.participants)
  )
)
with check (
  exists (
    select 1
    from public.conversations c
    where c.id = public.messages.conversation_id
      and auth.uid() = ANY(c.participants)
  )
);

-- Admin full control
create policy "Admin can manage all messages"
on public.messages
for all
using ( public.is_admin(auth.uid()) )
with check ( public.is_admin(auth.uid()) );

-- Optional: convenience view
create or replace view public.v_my_conversations as
select
  c.id,
  c.participants,
  c.last_message,
  c.last_message_at,
  c.created_at,
  c.updated_at
from public.conversations c
where auth.uid() = ANY(c.participants);

