-- MashixTalk: private cloud storage for photos, videos and audio in direct messages.
-- Run once in Supabase SQL Editor.
-- Files are private. Only the sender and the recipient of a message containing
-- the stored object path can create a signed download URL.

INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('chat-media', 'chat-media', false, 52428800)
ON CONFLICT (id) DO UPDATE
SET public = false, file_size_limit = 52428800, allowed_mime_types = NULL;

DROP POLICY IF EXISTS "MashixTalk users upload own chat media" ON storage.objects;
CREATE POLICY "MashixTalk users upload own chat media"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'chat-media'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
);

DROP POLICY IF EXISTS "MashixTalk participants read chat media" ON storage.objects;
CREATE POLICY "MashixTalk participants read chat media"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'chat-media'
  AND (
    (storage.foldername(name))[1] = (SELECT auth.uid())::text
    OR EXISTS (
      SELECT 1
      FROM public.messages m
      WHERE (m.sender_id = (SELECT auth.uid()) OR m.receiver_id = (SELECT auth.uid()))
        AND m.content LIKE '%' || storage.objects.name || '%'
    )
  )
);

DROP POLICY IF EXISTS "MashixTalk users delete own chat media" ON storage.objects;
CREATE POLICY "MashixTalk users delete own chat media"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'chat-media'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
);
