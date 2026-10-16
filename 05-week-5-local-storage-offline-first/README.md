# Praktikum 5: Local Storage & Offline-First

## AI Verification Checklist

1. **Apakah AI menempatkan daftar catatan di SharedPreferences?**
   Tidak. Rekomendasi teknis yang dihasilkan menolak dengan tegas penempatan koleksi (daftar catatan) ke dalam SharedPreferences karena strukturnya yang berisiko rusak jika dibongkar-pasang (decode/encode array) secara terus-menerus. AI menyarankan SQLite.
2. **Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?**
   Ya, skema yang disusun secara eksplisit memiliki kolom dirty (integer 0/1) sebagai penanda antrean sinkronisasi, dan kolom updated_at untuk menyimpan urutan modifikasi catatan.
3. **Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?**
   Klaim terkait SQLite (sqflite) secara eksplisit diakui *tidak* real-time (tidak mendukung stream bawaan), melainkan harus disegarkan menggunakan fungsi `invalidate` dari Riverpod. Sedangkan untuk alternatif seperti Drift, AI benar-benar mencantumkan bahwa hal itu didukung penuh aliran data (stream) reaktif dari basis datanya.
4. **Apakah estimasi boilerplate AI masuk akal setelah Anda mencoba instalasinya?**
   Sangat masuk akal. Memang dengan sqflite dibutuhkan sedikit boilerplate manual seperti pemetaan (toMap/fromMap) dan penulisan syntax SQL murni, namun lebih sederhana dibandingkan keharusan mengonfigurasi generator kode (build_runner) terus menerus sejak awal (jika menggunakan Drift).
5. **Keputusan final beserta alasannya**
   Keputusan final adalah menggunakan SharedPreferences khusus untuk preferensi (tema/status) dan SQLite (sqflite) untuk koleksi catatan. Alasannya karena SharedPreferences dirancang sempurna untuk menyimpan bacaan data primitif secara cepat, sementara SQLite sanggup memilah ribuan catatan berdasarkan waktu ubah (updated_at) secara efisien tanpa masalah memori berlebih.

---

## Checklist verifikasi mandiri

- [x] **UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider.** 
  Terpenuhi. Seluruh proses akses basis data melewati kelas Repository (seperti NoteRepository dan SyncRepository) lalu disalurkan ke antarmuka menggunakan Riverpod.
- [x] **Aplikasi penuh berfungsi dalam mode pesawat: baca, tambah, hapus catatan.**
  Sudah diuji coba. Catatan yang ditambahkan di mode offline berhasil disimpan, dibaca, dan dihapus secara lancar karena semuanya dituliskan murni ke penyimpanan internal SQLite.
- [x] **Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet.**
  Terverifikasi. Peringatan sinkronisasi dengan icon awan jingga akan terus terlihat hingga tombol "Sync" dipanggil. Halaman Data API juga otomatis me-load dari tabel cache lokal jika gagal menghubungi server atau saat `forceOffline` menyala.
- [x] **flutter analyze tanpa issue dan semua test lulus.**
  Perintah analisis berhasil dieksekusi tanpa menemui masalah logis maupun arsitektural (lint).
- [x] **Hasil AI diverifikasi dan didokumentasikan pada folder docs/.**
  Selesai. Dokumen analisis *storage* AI Challenge dapat ditinjau di dalam `docs/ai_challenge.md`.

---

## Refleksi

- **Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?**
  Menyimpan ribuan catatan di dalam SharedPreferences berarti seluruh entri data tersebut harus diserialisasi menjadi satu JSON raksasa yang sangat membebani RAM tiap kali akan dibaca atau diperbarui sebagian. Jika terjadi *crash* di tengah proses penyimpanan, seluruh daftar catatan tersebut bisa *corrupt* (rusak secara keseluruhan).
- **Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain?**
  Strategi *cache-first* (mendahulukan data lokal) amat sangat memadai untuk membaca artikel, halaman detail profil, catatan, di mana versi data lama sekalipun tetap relevan untuk dilihat sementara menunggu jaringan normal. Namun, strategi *network-first* wajib digunakan untuk transaksi yang memerlukan validitas absolut, seperti pembelian barang, dompet mata uang (saldo bank), atau ketersediaan stok kursi.
- **Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?**
  Setiap catatan yang baru ditulis ditandai (*dirty*) lalu dimasukkan ke database lokal seketika. UI merespons sukses saat itu juga secara sinkron tanpa jeda, membuat aplikasi terasa instan. Di latar belakang, fungsi penyinkron mengumpulkan (filter) semua catatan kotor dan memompa datanya ke *server*. Label dilepas (*clean*) ketika pengiriman selesai. Namun jika alur pengubahan obyek mengharuskan sejarah aksi spesifik dikirim persis berurutan (misal: di-*update* lalu di-*delete* saat tak ada jaringan), pendekatan tabel antrean terpisah (*outbox pattern*) akan amat sangat diperlukan untuk menghindari tabrakan state.
- **Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?**
  Semua bagian terkait implementasi penyimpanan objek koleksi ke SharedPreferences secara insting langsung ditolak. Selanjutnya, secara arsitektur kami menghindari pemilihan paket kompleks seperti Drift pada aplikasi mini (agar struktur dan pemahaman dasar logika pemetaan bisa dipelajari tanpa lapisan magis ORM), serta menolak Hive karena aplikasi catatan membutuhkan fleksibilitas SQL pengurutan berbasis waktu (`ORDER BY`).
