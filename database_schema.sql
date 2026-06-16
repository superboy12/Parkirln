-- SQL Schema for SmartPark Unila (Supabase) - FULLY AUTONOMOUS GPS VERSION
-- Please run this script in your Supabase SQL Editor.

-- Hapus tabel lama jika ada
DROP TABLE IF EXISTS public.reservations;
DROP TABLE IF EXISTS public.parking_sessions;
DROP TABLE IF EXISTS public.sos_logs;
DROP TABLE IF EXISTS public.slots;
DROP TABLE IF EXISTS public.parking_areas;
DROP TABLE IF EXISTS public.users;

-- 1. Tabel users (Memanfaatkan auth.users dari Supabase untuk profil)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  nama_lengkap TEXT NOT NULL,
  no_plat TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, nama_lengkap)
  VALUES (new.id, new.email, COALESCE(new.raw_user_meta_data->>'nama_lengkap', 'User'));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 2. Tabel parking_areas
CREATE TABLE public.parking_areas (
  id TEXT PRIMARY KEY,
  nama_area TEXT NOT NULL,
  total_slot INTEGER NOT NULL,
  available_slot INTEGER NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  radius_geofence_m INTEGER DEFAULT 50 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.parking_areas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view parking areas" ON public.parking_areas FOR SELECT USING (true);

-- Insert dummy data for parking areas (Koordinat disesuaikan sekitar Unila)
INSERT INTO public.parking_areas (id, nama_area, total_slot, available_slot, latitude, longitude, radius_geofence_m) VALUES 
('area_ti', 'Teknik Informatika', 50, 20, -5.3653, 105.2445, 50),
('area_sipil', 'Teknik Sipil', 40, 0, -5.3640, 105.2450, 50),
('area_rektorat', 'Rektorat', 30, 5, -5.3620, 105.2430, 80);

-- 3. Tabel slots
CREATE TABLE public.slots (
  slot_id TEXT PRIMARY KEY,
  parking_id TEXT REFERENCES public.parking_areas(id) ON DELETE CASCADE,
  nomor_slot TEXT NOT NULL,
  jenis_kendaraan TEXT DEFAULT 'Mobil' CHECK (jenis_kendaraan IN ('Motor', 'Mobil')),
  status TEXT DEFAULT 'Tersedia' CHECK (status IN ('Tersedia', 'Terisi')),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.slots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view slots" ON public.slots FOR SELECT USING (true);
-- Untuk simulasi client-side, kita izinkan user update status slot saat check-in/out
CREATE POLICY "Users can update slots status" ON public.slots FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Insert dummy slots for Teknik Informatika (Kordinat dibuat di sekitar area TI)
DO $$
DECLARE
  i INT;
  lat_base DOUBLE PRECISION := -5.3653;
  lng_base DOUBLE PRECISION := 105.2445;
BEGIN
  -- A1 to A12 (Mobil)
  FOR i IN 1..12 LOOP 
    INSERT INTO public.slots (slot_id, parking_id, nomor_slot, jenis_kendaraan, latitude, longitude) 
    VALUES ('ti_A'||i, 'area_ti', 'A'||i, 'Mobil', lat_base + (i*0.00001), lng_base + 0.00001); 
  END LOOP;
  -- B1 to B12 (Mobil)
  FOR i IN 1..12 LOOP 
    INSERT INTO public.slots (slot_id, parking_id, nomor_slot, jenis_kendaraan, latitude, longitude) 
    VALUES ('ti_B'||i, 'area_ti', 'B'||i, 'Mobil', lat_base + (i*0.00001), lng_base + 0.00005); 
  END LOOP;
  -- C1 to C15 (Motor)
  FOR i IN 1..15 LOOP 
    INSERT INTO public.slots (slot_id, parking_id, nomor_slot, jenis_kendaraan, latitude, longitude) 
    VALUES ('ti_C'||i, 'area_ti', 'C'||i, 'Motor', lat_base + (i*0.00001), lng_base + 0.00010); 
  END LOOP;
END $$;

-- 4. Tabel parking_sessions (Menggantikan reservations)
CREATE TABLE public.parking_sessions (
  id TEXT PRIMARY KEY,
  uid UUID REFERENCES public.users(id) NOT NULL,
  parking_id TEXT REFERENCES public.parking_areas(id) NOT NULL,
  slot_id TEXT REFERENCES public.slots(slot_id) NOT NULL,
  plat_nomor TEXT NOT NULL,
  check_in_time TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  check_out_time TIMESTAMP WITH TIME ZONE,
  check_in_lat DOUBLE PRECISION NOT NULL,
  check_in_lng DOUBLE PRECISION NOT NULL,
  foto_masuk_url TEXT NOT NULL,
  foto_keluar_url TEXT,
  status TEXT DEFAULT 'Aktif' CHECK (status IN ('Aktif', 'Selesai')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.parking_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own sessions" ON public.parking_sessions FOR SELECT USING (auth.uid() = uid);
CREATE POLICY "Users can insert their own sessions" ON public.parking_sessions FOR INSERT WITH CHECK (auth.uid() = uid);
CREATE POLICY "Users can update their own sessions" ON public.parking_sessions FOR UPDATE USING (auth.uid() = uid);

-- 5. Tabel sos_logs
CREATE TABLE public.sos_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  uid UUID REFERENCES public.users(id) NOT NULL,
  session_id TEXT REFERENCES public.parking_sessions(id) ON DELETE CASCADE,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.sos_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert sos" ON public.sos_logs FOR INSERT WITH CHECK (auth.uid() = uid);

-- Buat Storage Bucket untuk foto dokumentasi (Jika tidak bisa via SQL, akan dibuat manual)
INSERT INTO storage.buckets (id, name, public) VALUES ('parking_docs', 'parking_docs', true) ON CONFLICT DO NOTHING;
CREATE POLICY "Anyone can upload photos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'parking_docs' AND auth.uid() IS NOT NULL);
CREATE POLICY "Anyone can view photos" ON storage.objects FOR SELECT USING (bucket_id = 'parking_docs');
