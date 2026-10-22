-- MashixTalk: облачные фоны профилей
-- Выполни этот скрипт в Supabase Dashboard -> SQL Editor перед публикацией обновлённого сайта.
-- Изображения фона хранятся в уже используемом публичном bucket profile-media.

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS cover_image_url text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS cover_color text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS decoration text DEFAULT 'sunset';

-- Сохранить существующие значения и задать оформление для старых профилей.
UPDATE public.profiles SET decoration = 'sunset' WHERE decoration IS NULL;
