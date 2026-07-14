// File konfigurasi Supabase
// Ganti dengan Project URL dan Anon Key dari proyek Supabase kamu!
const SUPABASE_URL = "https://oeploetqpygaradsdpaa.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9lcGxvZXRxcHlnYXJhZHNkcGFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQwMjU2MzcsImV4cCI6MjA5OTYwMTYzN30.Be6uLur7OZ44GT1X8PYnrjc2eY7WXnqsLVe9beP3Vxs";

const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Helper function untuk mendapatkan atau membuat siswa
async function getOrCreateSiswa(nama_lengkap, nomor_absen) {
  // Coba cari siswa yang sudah ada
  let { data: existingSiswa, error } = await supabaseClient
    .from("siswa")
    .select("*")
    .eq("nama_lengkap", nama_lengkap)
    .eq("nomor_absen", nomor_absen)
    .single();

  if (error && error.code !== "PGRST116") {
    console.error("Error mencari siswa:", error);
    return null;
  }

  if (existingSiswa) {
    // Update terakhir_aktif dan set is_logout = false
    const { data: updatedSiswa, error: updateError } = await supabaseClient
      .from("siswa")
      .update({ terakhir_aktif: new Date().toISOString(), is_logout: false })
      .eq("id", existingSiswa.id)
      .select()
      .single();

    if (updateError) console.error("Error update siswa:", updateError);
    return updatedSiswa || existingSiswa;
  }

  // Jika tidak ada, buat baru
  const { data: newSiswa, error: insertError } = await supabaseClient
    .from("siswa")
    .insert({ nama_lengkap, nomor_absen, is_logout: false })
    .select()
    .single();

  if (insertError) console.error("Error buat siswa:", insertError);
  return newSiswa;
}

// Helper function untuk logout siswa
async function logoutSiswaFromSupabase(siswaId) {
  if (!siswaId) return;
  const { error } = await supabaseClient
    .from("siswa")
    .update({ is_logout: true, terakhir_aktif: new Date().toISOString() })
    .eq("id", siswaId);
  if (error) console.error("Error logout siswa:", error);
}

// Helper function untuk simpan riwayat percobaan
async function saveRiwayatToSupabase(id_siswa, nama_gigi, urutan_jawaban_siswa, status_jawaban) {
  const { data, error } = await supabaseClient
    .from("riwayat")
    .insert({ id_siswa, nama_gigi, urutan_jawaban_siswa, status_jawaban })
    .select();
  if (error) console.error("Error simpan riwayat:", error);
  return data;
}

// Helper function untuk update terakhir_aktif secara berkala
let keepAliveIntervalSupabase = null;
async function startKeepAliveSupabase(siswaId) {
  if (keepAliveIntervalSupabase) clearInterval(keepAliveIntervalSupabase);
  // Update pertama
  await supabaseClient
    .from("siswa")
    .update({ terakhir_aktif: new Date().toISOString(), is_logout: false })
    .eq("id", siswaId);
  // Update setiap 30 detik
  keepAliveIntervalSupabase = setInterval(async () => {
    await supabaseClient
      .from("siswa")
      .update({ terakhir_aktif: new Date().toISOString(), is_logout: false })
      .eq("id", siswaId);
  }, 30000);
}

function stopKeepAliveSupabase() {
  if (keepAliveIntervalSupabase) {
    clearInterval(keepAliveIntervalSupabase);
    keepAliveIntervalSupabase = null;
  }
}

