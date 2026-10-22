-- MashixTalk: shared reactions for messages with BIGINT IDs
-- Run in Supabase SQL Editor.

create table if not exists public.message_reactions (
  message_id bigint not null
    references public.messages(id) on delete cascade,
  user_id uuid not null
    references auth.users(id) on delete cascade,
  emoji text not null
    check (emoji in ('❤️','😂','👍','🔥','😮','😢','👏','🎉')),
  created_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

alter table public.message_reactions enable row level security;
grant select, insert, update, delete on public.message_reactions to authenticated;

drop policy if exists "Chat participants can read message reactions" on public.message_reactions;
create policy "Chat participants can read message reactions"
on public.message_reactions for select to authenticated
using (
  exists (
    select 1 from public.messages m
    where m.id = message_reactions.message_id
      and (m.sender_id = (select auth.uid()) or m.receiver_id = (select auth.uid()))
  )
);

drop policy if exists "Chat participants can add own message reactions" on public.message_reactions;
create policy "Chat participants can add own message reactions"
on public.message_reactions for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.messages m
    where m.id = message_reactions.message_id
      and (m.sender_id = (select auth.uid()) or m.receiver_id = (select auth.uid()))
  )
);

drop policy if exists "Users can update own message reactions" on public.message_reactions;
create policy "Users can update own message reactions"
on public.message_reactions for update to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.messages m
    where m.id = message_reactions.message_id
      and (m.sender_id = (select auth.uid()) or m.receiver_id = (select auth.uid()))
  )
);

drop policy if exists "Users can delete own message reactions" on public.message_reactions;
create policy "Users can delete own message reactions"
on public.message_reactions for delete to authenticated
using (user_id = (select auth.uid()));
