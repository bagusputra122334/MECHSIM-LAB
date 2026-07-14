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

-- 3. Enable Row Level Security (RLS) untuk keamanan dasar
ALTER TABLE siswa ENABLE ROW LEVEL SECURITY;
ALTER TABLE riwayat ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations on siswa" ON siswa
  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on riwayat" ON riwayat
  FOR ALL USING (true) WITH CHECK (true);

-- 4. Enable Realtime!
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE siswa, riwayat;
COMMIT;

