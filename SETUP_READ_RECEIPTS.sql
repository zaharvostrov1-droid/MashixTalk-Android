-- Execute once in Supabase SQL Editor.
alter table public.messages add column if not exists read_at timestamptz;
create or replace function public.mark_chat_read(other_user uuid)
returns void language sql security definer set search_path = ''
as $$
 update public.messages
 set read_at = now()
 where receiver_id = (select auth.uid())
   and sender_id = other_user
   and read_at is null;
$$;
revoke all on function public.mark_chat_read(uuid) from public;
grant execute on function public.mark_chat_read(uuid) to authenticated;
