# Panduan Setup Supabase untuk Realtime Sync

## Langkah 1: Buat Proyek Supabase
1. Buka [supabase.com](https://supabase.com/) dan buat akun (jika belum punya)
2. Klik "New Project", isi nama proyek, password, dan pilih region (Singapore/Asia Tenggara)
3. Tunggu sampai proyek ready (sekitar 2-3 menit)

## Langkah 2: Setup Tabel
1. Di dashboard proyek Supabase, buka **SQL Editor** → **New Query**
2. Copy paste kode SQL di bawah dan klik **Run**:
   ```sql
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

   CREATE POLICY "Allow all operations on siswa" ON siswa FOR ALL USING (true) WITH CHECK (true);
   CREATE POLICY "Allow all operations on riwayat" ON riwayat FOR ALL USING (true) WITH CHECK (true);

   -- 4. Enable Realtime!
   BEGIN;
     DROP PUBLICATION IF EXISTS supabase_realtime;
     CREATE PUBLICATION supabase_realtime FOR TABLE siswa, riwayat;
   COMMIT;
   ```

## Langkah 3: Konfigurasi Client
1. Di dashboard Supabase, buka **Settings** → **API**
2. Salin:
   - `Project URL` (contoh: `https://abcdefghijklmnopqrst.supabase.co`)
   - `anon public` key (contoh: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)
3. Buka file `js/supabaseClient.js`
4. Ganti:
   - `GANTI_DENGAN_PROJECT_URL_KAMU` dengan Project URL kamu
   - `GANTI_DENGAN_ANON_KEY_KAMU` dengan Anon Key kamu

## Langkah 4: Test!
1. Buka `simulasimain.html` → login
2. Buka `guru_dashboard.html` di perangkat lain → kamu harus melihat siswa online secara realtime!

