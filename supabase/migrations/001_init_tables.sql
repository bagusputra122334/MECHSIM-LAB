-- 1. Buat tabel siswa
CREATE TABLE IF NOT EXISTS siswa (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  nama_lengkap TEXT NOT NULL,
  nomor_absen TEXT NOT NULL,
  kelas TEXT DEFAULT 'XI',
  waktu_login TIMESTAMPTZ DEFAULT NOW(),
  terakhir_aktif TIMESTAMPTZ DEFAULT NOW(),
  is_logout BOOLEAN DEFAULT TRUE,
  UNIQUE(nama_lengkap, nomor_absen)
);

-- 2. Buat tabel riwayat percobaan
CREATE TABLE IF NOT EXISTS riwayat (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  id_siswa BIGINT REFERENCES siswa(id) ON DELETE CASCADE,
  nama_gigi TEXT NOT NULL,
  urutan_jawaban_siswa TEXT,
  status_jawaban TEXT NOT NULL CHECK (status_jawaban IN ('Benar', 'Salah')),
  waktu_percobaan TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Buat tabel app_state untuk state global (misal freeze layar)
CREATE TABLE IF NOT EXISTS app_state (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Buat tabel sos_requests untuk permintaan bantuan siswa
CREATE TABLE IF NOT EXISTS sos_requests (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  id_siswa BIGINT REFERENCES siswa(id) ON DELETE CASCADE,
  nama_gigi TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Enable Row Level Security (RLS) untuk keamanan dasar
ALTER TABLE siswa ENABLE ROW LEVEL SECURITY;
ALTER TABLE riwayat ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE sos_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations on siswa" ON siswa
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on riwayat" ON riwayat
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on app_state" ON app_state
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on sos_requests" ON sos_requests
  FOR ALL USING (true) WITH CHECK (true);

-- 6. Insert initial freeze state (false = tidak dibekukan)
INSERT INTO app_state (key, value) 
VALUES ('freeze', 'false')
ON CONFLICT (key) DO NOTHING;

-- 7. Enable Realtime!
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE siswa, riwayat, app_state, sos_requests;
COMMIT;

