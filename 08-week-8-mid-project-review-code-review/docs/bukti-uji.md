# Bukti Uji Minggu 8

## Perubahan yang diverifikasi

- Halaman daftar, aksi tambah/hapus, dan halaman detail menggunakan provider feature-first. Repository lama masih dipakai khusus untuk sinkronisasi sampai alur sinkronisasi dimigrasikan.
- Form tambah catatan menghindari no-op bila `FormState` tidak tersedia dan menampilkan pesan aman pada kegagalan simpan.
- Widget test mengunci input invalid tidak disimpan, input valid diteruskan ke repository, dan kegagalan penyimpanan tidak menampilkan detail internal ke UI.

## Output perintah

Perintah formatter dijalankan dari root repository pada file Dart yang disentuh:

```text
dart format 08-week-8-mid-project-review-code-review\week5_offline_notes\lib\pages\notes_page.dart 08-week-8-mid-project-review-code-review\week5_offline_notes\lib\pages\note_detail_page.dart 08-week-8-mid-project-review-code-review\week5_offline_notes\lib\features\notes\presentation\providers\notes_providers.dart 08-week-8-mid-project-review-code-review\week5_offline_notes\lib\widgets\note_tile.dart 08-week-8-mid-project-review-code-review\week5_offline_notes\test\validate_note_test.dart
Formatted 08-week-8-mid-project-review-code-review\week5_offline_notes\lib\pages\notes_page.dart
Formatted 08-week-8-mid-project-review-code-review\week5_offline_notes\test\validate_note_test.dart
Formatted 5 files (2 changed) in 0.07 seconds.
```

Pemeriksaan format CI dijalankan dari folder proyek Flutter:

```text
dart format --set-exit-if-changed lib test
Formatted 22 files (0 changed) in 0.19 seconds.
```

`flutter analyze` dijalankan dari `08-week-8-mid-project-review-code-review\week5_offline_notes`:

```text
Analyzing week5_offline_notes...
No issues found! (ran in 12.2s)
```

`flutter test` dijalankan dari folder yang sama:

```text
00:00 +0: loading ...\test/get_notes_test.dart
00:00 +1: GetNotes meneruskan daftar dari repository
00:00 +2: GetNotes meneruskan failure tanpa melempar
00:00 +3: GetNotes mengembalikan daftar kosong bila repository kosong
00:00 +4: menolak judul kosong
00:00 +5: menolak judul yang hanya berisi spasi
00:00 +6: menerima judul valid
00:00 +7: menerima judul valid yang diapit spasi
00:00 +8: dialog menampilkan error saat judul kosong disimpan
00:00 +9: dialog menyimpan judul valid
Failed to save note: database detail should not reach UI
00:00 +10: halaman daftar menampilkan catatan dari feature provider
00:00 +11: halaman detail membaca catatan dari feature provider
00:00 +12: aksi hapus memperbarui daftar catatan
00:00 +13: All tests passed!
```

Baris `Failed to save note: ...` adalah log diagnostik yang sengaja dihasilkan oleh fake repository untuk skenario test gagal-simpan; output test menyatakan seluruh 13 test lulus. Satu percobaan `flutter analyze` saat dijalankan paralel dengan test gagal mengakses file cache engine bersama; setelah menjalankannya terpisah, analyzer lulus seperti ditunjukkan di atas.

## Uji manual — maksimal 5 menit

Belum dijalankan secara manual. Jalankan aplikasi pada emulator/perangkat, lalu lakukan skenario berikut (perkiraan 3–5 menit):

1. Buka halaman Catatan dan pilih tombol tambah.
2. Tekan **Simpan** dengan judul kosong; pastikan pesan validasi tampil dan dialog tetap terbuka.
3. Isi judul dengan spasi saja; pastikan validasi tetap menolak.
4. Isi judul dan isi catatan, simpan; pastikan catatan tampil di daftar.
5. Buka detail catatan dan pastikan judul serta isi sesuai.
6. Kembali ke daftar dan hapus catatan; pastikan daftar diperbarui.

## Placeholder screenshot

Simpan bukti manual setelah pengambilan screenshot; placeholder ini bukan screenshot yang sudah diambil.

- `screenshots/notes-validation-error.png` — pesan validasi untuk judul kosong/whitespace.
- `screenshots/notes-feature-first-crud.png` — catatan tersimpan di daftar atau halaman detail.
- `screenshots/notes-delete-result.png` — daftar setelah catatan dihapus.
