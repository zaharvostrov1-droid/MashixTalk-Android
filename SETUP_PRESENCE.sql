-- Run once in Supabase SQL Editor.
create table if not exists public.user_presence (
 user_id uuid primary key references auth.users(id) on delete cascade,
 last_seen timestamptz not null default now()
);
alter table public.user_presence enable row level security;
grant select, insert, update on public.user_presence to authenticated;
drop policy if exists "Authenticated users can read presence" on public.user_presence;
create policy "Authenticated users can read presence" on public.user_presence
 for select to authenticated using (true);
drop policy if exists "Users can insert own presence" on public.user_presence;
create policy "Users can insert own presence" on public.user_presence
 for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Users can update own presence" on public.user_presence;
create policy "Users can update own presence" on public.user_presence
 for update to authenticated
 using ((select auth.uid()) = user_id)
 with check ((select auth.uid()) = user_id);
