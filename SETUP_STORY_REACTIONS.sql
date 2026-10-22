-- MashixTalk: реакции ❤️ на истории.
-- Выполнить в Supabase Dashboard -> SQL Editor -> Run.
-- Реакцию может поставить только вошедший пользователь и только на чужую историю.

create table if not exists public.story_reactions (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint story_reactions_one_per_user unique (story_id, user_id)
);

alter table public.story_reactions enable row level security;

grant select, insert, delete on public.story_reactions to authenticated;

drop policy if exists "MashixTalk users read story reactions" on public.story_reactions;
create policy "MashixTalk users read story reactions"
on public.story_reactions for select to authenticated
using (true);

drop policy if exists "MashixTalk users react to others stories" on public.story_reactions;
create policy "MashixTalk users react to others stories"
on public.story_reactions for insert to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.stories s
    where s.id = story_id
      and s.user_id <> auth.uid()
      and s.expires_at > now()
  )
);

drop policy if exists "MashixTalk users remove own story reactions" on public.story_reactions;
create policy "MashixTalk users remove own story reactions"
on public.story_reactions for delete to authenticated
using (user_id = auth.uid());

create index if not exists story_reactions_story_id_idx on public.story_reactions(story_id);
