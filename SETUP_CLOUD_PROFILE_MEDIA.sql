-- MashixTalk: облачные фото и музыка профиля через Supabase Storage
-- Выполни весь скрипт в Supabase Dashboard -> SQL Editor.

alter table public.profiles add column if not exists music_url text;
alter table public.profiles add column if not exists music_title text;
alter table public.profiles add column if not exists music_cover_url text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-media', 'profile-media', true, 15728640,
  array['image/jpeg','image/png','image/webp','image/gif','audio/mpeg','audio/mp3','audio/mp4','audio/aac','audio/ogg','audio/wav','audio/webm','audio/x-m4a']
)
on conflict (id) do update set public = true, file_size_limit = 15728640, allowed_mime_types = excluded.allowed_mime_types;

-- Public read is intentional: profile pictures and selected profile tracks are public profile content.
drop policy if exists "Profile media public read" on storage.objects;
create policy "Profile media public read" on storage.objects for select using (bucket_id = 'profile-media');

drop policy if exists "Users upload own profile media" on storage.objects;
create policy "Users upload own profile media" on storage.objects for insert to authenticated
with check (bucket_id = 'profile-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users update own profile media" on storage.objects;
create policy "Users update own profile media" on storage.objects for update to authenticated
using (bucket_id = 'profile-media' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'profile-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users delete own profile media" on storage.objects;
create policy "Users delete own profile media" on storage.objects for delete to authenticated
using (bucket_id = 'profile-media' and (storage.foldername(name))[1] = auth.uid()::text);

-- Make sure public profiles can be read and authenticated users can update only their own row.
-- Keep existing RLS policies if already configured; do not disable RLS.
