-- MashixTalk: подготовка публичного Supabase Storage для историй.
-- Выполнить в Supabase Dashboard -> SQL Editor -> Run.
-- Не вставляйте сюда service_role key и не отключайте RLS.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('stories', 'stories', true, 26214400, array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm','video/quicktime'])
on conflict (id) do update set
  public = true,
  file_size_limit = 26214400,
  allowed_mime_types = excluded.allowed_mime_types;

-- Каждый пользователь может загружать файлы только в папку со своим UUID.
create policy "MashixTalk users upload own stories"
on storage.objects for insert to authenticated
with check (bucket_id = 'stories' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "MashixTalk users update own story files"
on storage.objects for update to authenticated
using (bucket_id = 'stories' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'stories' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "MashixTalk users delete own story files"
on storage.objects for delete to authenticated
using (bucket_id = 'stories' and (storage.foldername(name))[1] = auth.uid()::text);

-- Публичное чтение нужно, чтобы другие пользователи могли видеть медиа историй.
create policy "MashixTalk public read story files"
on storage.objects for select to public
using (bucket_id = 'stories');
