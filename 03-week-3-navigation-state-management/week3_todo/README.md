# Praktikum 2

![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum2a.png)


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum2b.png)


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum2c.png)


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum2d.png)

# Praktikum 3


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum3a.png)


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum3b.png)


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum3c.png)


![mini](/03-week-3-navigation-state-management/Screenshot/Praktikum3d.png)

Kenapa menampilkan data lama + indikator refresh kadang lebih baik daripada mengosongkan layar?

Karena:

1. Konteks tidak hilang. Kalau layar dikosongkan total saat refresh, pengguna kehilangan apa yang sedang dilihat. Kalau data lama tetap tampil + ada indikator kecil (misal spinner di AppBar), pengguna tetap punya konteks.

2. Terasa lebih cepat. Mengganti seluruh layar jadi spinner terasa "berat". Menampilkan data lama + refresh halus terasa "ringan".

3. Menghindari flicker. Layar yang berkedip antara konten dan spinner mengganggu.

4. Data lama sering masih valid. Untuk kasus seperti feed berita, daftar produk, atau dashboard, data 1 menit lalu biasanya masih berguna.


# Praktikum AI


![mini](/03-week-3-navigation-state-management/Screenshot/AI.png)


![mini](/03-week-3-navigation-state-management/Screenshot/AI2a.png)


![mini](/03-week-3-navigation-state-management/Screenshot/AI2b.png)


# Praktikum Refactoring dan testing


![mini](/03-week-3-navigation-state-management/Screenshot/testing1a.png)


![mini](/03-week-3-navigation-state-management/Screenshot/testing1b.png)


![mini](/03-week-3-navigation-state-management/Screenshot/testing1c.png)


# Refleksi
1. Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?

setState cukup saat state hanya dipakai satu widget dan umurnya pendek, misalnya buka/tutup dialog atau isi TextField. State harus naik ke Riverpod saat dipakai banyak widget/halaman, harus bertahan meski widget sudah tidak tampil, atau perlu diuji tanpa UI. Kalau muncul gejala prop drilling atau state asinkron, itu tanda harus pakai Riverpod.

2. Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?

context.go mengganti stack — halaman lama dibuang, tombol back tidak kembali. Cocok untuk pindah tab, redirect login, atau logout. context.push menumpuk halaman baru di atas stack — tombol back kembali ke halaman sebelumnya. Cocok untuk buka halaman detail. Di aplikasi saya, NavigationBar pakai context.go karena tab sifatnya sejajar, bukan bertingkat.

3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?

Tiga boolean (isLoading, hasError, data) bisa tidak konsisten — misal loading dan error true sekaligus — dan rawan lupa direset. AsyncValue hanya punya satu kondisi pada satu waktu: loading, error, atau data. when() memaksa ketiganya ditangani, kalau tidak kode tidak compile. AsyncValue.guard juga otomatis menangkap error, jadi tidak perlu try/catch manual.

4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?

Saya perbaiki dua hal. Pertama, test error dari AI bergantung pada angka acak 30% sehingga hasilnya kadang lulus kadang gagal; saya ubah jadi deterministik dengan parameter forceFail dan overrideWith. Kedua, refresh() di AI memanggil build() langsung; saya pisah logikanya ke _fetch() supaya tidak ada duplikasi dan build() tetap jadi pintu masuk yang bersih.

# AI Prompt
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.

| No | Poin Verifikasi | Hasil Pengecekan |
|---|---|---|
| 1 | State diubah aman? | Ya, pakai `AsyncNotifier`, tidak ada mutasi list langsung. |
| 2 | `ref` ditempatkan benar? | Ya, `watch` di build, `read` di callback tombol. |
| 3 | Tiga skenario `AsyncValue` ditangani? | Ya, loading, error, dan data semua ada di `.when()`. |
| 4 | Provider diketik eksplisit? | Ya, `AsyncNotifierProvider<StatsNotifier, List<String>>`. |
| 5 | Arsitektur mutakhir? | Ya, `AsyncNotifier` + `ConsumerWidget`, tanpa API lama. |
| 6 | Lulus uji? | `flutter analyze` bersih, `flutter test` lulus. |

catatan: Saya menambahkan tanda backtick pada beberapa kata kunci teknis seperti ref, AsyncNotifier, dll. agar tampilannya lebih rapi dan membedakan antara teks biasa dengan kode program, namun isi teksnya tetap 100% sama seperti yang sudah ada di modul
