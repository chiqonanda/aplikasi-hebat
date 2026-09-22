-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: tambah kolom lokasi & jam operasional pada tabel bank_sampah
-- Cara pakai: jalankan di SQL Editor Supabase (Dashboard → SQL Editor → New query)
-- Semua kolom opsional (NULL) agar data lama tetap valid.
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.bank_sampah
  ADD COLUMN IF NOT EXISTS latitude double precision,
  ADD COLUMN IF NOT EXISTS longitude double precision,
  ADD COLUMN IF NOT EXISTS jam_operasional text;

COMMENT ON COLUMN public.bank_sampah.latitude IS 'Latitude lokasi bank sampah (null = belum disetel)';
COMMENT ON COLUMN public.bank_sampah.longitude IS 'Longitude lokasi bank sampah (null = belum disetel)';
COMMENT ON COLUMN public.bank_sampah.jam_operasional IS 'Jam operasional, teks bebas mis. "Senin–Sabtu 08.00–16.00"';
