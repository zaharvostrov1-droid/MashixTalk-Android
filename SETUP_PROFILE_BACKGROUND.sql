-- MashixTalk: облачные фоны и оформление публичных профилей.
-- Совместимо с кодом приложения и SETUP_PROFILE_BACKGROUNDS.sql.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS cover_image_url TEXT,
  ADD COLUMN IF NOT EXISTS cover_color TEXT,
  ADD COLUMN IF NOT EXISTS decoration TEXT DEFAULT 'sunset';
UPDATE public.profiles SET decoration = 'sunset' WHERE decoration IS NULL;
