# Week 5 — Local Storage & Offline First

**Nama:** Arifah Zhafirah Wikananda
**NIM:** 244107020188
**Mata Kuliah:** Pemograman Mobile — Politeknik Negeri Malang

## Tujuan

Minggu ini saya membangun aplikasi **Offline Notes** untuk mempelajari penyimpanan data lokal di Flutter. Fokusnya adalah membedakan penyimpanan key-value, relasional, dan NoSQL; menyimpan preferensi dengan `SharedPreferences`; membuat CRUD catatan dengan SQLite (`sqflite`) lewat repository lokal; menerapkan pola offline-first (cache-first read, dirty flag, dan sinkronisasi); menampilkan state loading, error, empty, dan success dengan Riverpod; serta menguji repository dengan repository palsu tanpa database sungguhan.

## Ringkasan

| Komponen | Keterangan |
| --- | --- |
| Nama proyek | `week5_offline_notes` |
| Preferensi | `SharedPreferences` (tema gelap/terang, waktu terakhir dibuka) |
| Database | SQLite via `sqflite` (tabel `notes` dan `cached_posts`) |
| State management | `flutter_riverpod` (`AsyncNotifier`, `AsyncValue`) |
| Navigasi | `go_router` (halaman detail `/note/:id`) |
| Pola arsitektur | Repository pattern: UI hanya membaca provider, repository menjadi satu-satunya pintu ke database |
| Offline-first | Cache-first read, dirty flag, `syncNotes`, aturan konflik *last-write-wins* berdasarkan `updated_at` |

## Fitur Utama

- Toggle tema gelap/terang dan penyimpanan waktu terakhir aplikasi dibuka.
- CRUD catatan persisten di SQLite, diurutkan dari `updated_at` terbaru.
- Badge jumlah catatan yang belum tersinkron (`dirty`).
- Cache-first untuk data `GET /posts` JSONPlaceholder sehingga tetap tampil saat offline.
- Sinkronisasi simulasi (`syncNotes`) yang mengembalikan badge dirty menjadi 0.
- Halaman detail catatan yang membaca dari repository lokal.

## Teknologi

Flutter, Dart, `flutter_riverpod`, `shared_preferences`, `sqflite`, `path`, `dio`, `go_router`, `flutter_test`.

## Struktur Proyek

```
05-week-5-local-storage-offline-first/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   ├── local/
│   │   │   ├── db.dart
│   │   │   └── note.dart
│   │   ├── prefs.dart
│   │   ├── sync.dart
│   │   └── repositories/
│   │       └── note_repository.dart
│   ├── widgets/
│   │   └── note_tile.dart
│   └── pages/
│       ├── settings_page.dart
│       ├── notes_page.dart
│       └── note_detail_page.dart
├── test/
│   └── note_test.dart
├── docs/
├── screenshots/
└── README.md
```

## Cara Menjalankan

```bash
cd 05-week-5-local-storage-offline-first/week5_offline_notes
flutter pub get
flutter run
```

Jika baru menambahkan plugin (`shared_preferences` atau `sqflite`), hentikan aplikasi lalu jalankan ulang `flutter run` secara penuh, bukan hot reload, agar tidak muncul `MissingPluginException`.

Untuk analisis dan pengujian:

```bash
flutter analyze
flutter test
```

---

## Praktikum 1 — Repository Preferensi dan Halaman Pengaturan

Seluruh akses key-value dipusatkan di `lib/data/prefs.dart` melalui kelas `PrefsRepository`. Kelas ini menyimpan dua nilai: `dark_mode` (boolean) dan `last_opened_at` (string ISO 8601). Metode yang tersedia adalah `getDarkMode`, `setDarkMode`, `markOpenedNow`, dan `getLastOpened`. Widget tidak pernah memanggil `SharedPreferences.getInstance()` langsung.

Di `lib/pages/settings_page.dart`, repository dibungkus oleh `prefsRepositoryProvider`, lalu status tema diekspos lewat `darkModeProvider` berupa `AsyncNotifierProvider<DarkModeNotifier, bool>`. Fungsi `toggle()` mengubah state menjadi `AsyncLoading`, menyimpan nilai baru dengan `AsyncValue.guard`, lalu mengembalikan nilai hasilnya. Dengan pola ini hasil terbungkus rapi di provider sehingga mudah diuji dan tidak dibaca ulang berkali-kali di dalam `build()`.

**Hasil:**

| Tema terang | Tema gelap setelah toggle diaktifkan | Waktu terakhir dibuka tersimpan dan tampil kembali setelah aplikasi dibuka ulang |
| --- | --- | --- |
| ![Tema terang](/05-week-5-local-storage-offline-first/screenshot/Preferensi1a.png) | ![Tema gelap](/05-week-5-local-storage-offline-first/screenshot/Preferensi1b.png) | ![Tema terang](/05-week-5-local-storage-offline-first/screenshot/Preferensi1a.png) |

---

## Praktikum 2 — CRUD Catatan dengan SQLite

Model `Note` di `lib/data/local/note.dart` memiliki field `id`, `title`, `body`, `updatedAt`, dan `dirty`. Metode `toMap()` dan `Note.fromMap()` aman terhadap field yang hilang (null-safe), dan `dirty` diserialisasikan sebagai `0`/`1`.

Database dibuka lewat `openNotesDb()` di `lib/data/local/db.dart` dengan nama `offline_notes.db` versi 1. Saat `onCreate`, dibuat dua tabel: `notes` (`id`, `title`, `body`, `updated_at`, `dirty`) dan `cached_posts` (`id`, `payload`, `cached_at`).

`NoteRepository` di `lib/data/repositories/note_repository.dart` menjadi satu-satunya pintu data dengan metode `fetchNotes`, `addNote`, `deleteNote`, `countDirty`, dan `markAllSynced`. Constructor-nya menerima fungsi `openDb` agar pada pengujian database dapat diganti dengan versi palsu. Catatan baru selalu disimpan dengan `dirty = true` karena belum pernah disinkronkan. Halaman `notes_page.dart` menampilkan daftar catatan dengan badge jumlah catatan dirty, dan tetap berfungsi penuh dalam mode pesawat. Setiap mutasi diikuti `ref.invalidate(notesProvider)` agar UI ikut diperbarui.

**Hasil:**

| Kondisi awal (state empty) sebelum ada catatan | Menambahkan catatan baru | Daftar catatan dengan badge dirty |
| --- | --- | --- |
| ![State empty](/05-week-5-local-storage-offline-first/screenshot/CRUD1a.png) | ![Tambah catatan](/05-week-5-local-storage-offline-first/screenshot/CRUD1b.png) | ![Daftar catatan dengan badge dirty](/05-week-5-local-storage-offline-first/screenshot/CRUD1c.png) |

| Menghapus catatan | Data tetap ada setelah aplikasi ditutup total dan dibuka kembali (persisten) |
| --- | --- |
| ![Hapus catatan](/05-week-5-local-storage-offline-first/screenshot/CRUD1d.png) | ![Data persisten](/05-week-5-local-storage-offline-first/screenshot/CRUD1d.png) |

---

## Praktikum 3 — Offline-First: Cache, Sync, dan Simulasi Offline

**Cache-first read.** Fungsi `loadPostsCacheFirst()` membaca data `GET /posts` dari tabel `cached_posts` terlebih dahulu sehingga UI tidak kosong saat offline, lalu `refreshPostsInBackground()` mengambil data terbaru lewat Dio, menyimpannya ke cache, dan meng-invalidate provider.

**Sinkronisasi catatan dirty.** Karena belum ada backend tulis, server disimulasikan dengan `Future.delayed` selama satu detik. `syncNotes(repo)` menghitung catatan dirty dengan `countDirty()`, mengembalikan 0 jika tidak ada, dan jika ada akan memanggil `markAllSynced()` setelah "server" menjawab sukses, lalu mengembalikan jumlah catatan yang tersinkron. Fungsi ini diletakkan di `lib/data/sync.dart`.

**Aturan konflik.** Aplikasi ini memakai *last-write-wins* berdasarkan `updated_at`: jika data lokal dan data server sama-sama berubah, versi dengan `updated_at` paling baru yang dipertahankan. Aturan dibuat eksplisit agar sinkronisasi dua arah tidak menimpa data secara diam-diam.

**Simulasi offline.** Selain mode pesawat sungguhan, tersedia toggle `forceOffline` pada provider sehingga demo tidak bergantung pada kondisi Wi-Fi.

**Hasil:**

| Data posts tampil dari cache saat perangkat offline | Data posts tampil dari cache | Data posts tampil dari cache saat jaringan tersimpan |
| --- | --- | --- |
| ![Cache saat offline](/05-week-5-local-storage-offline-first/screenshot/Cache1c.jpeg) | ![Data dari cache](/05-week-5-local-storage-offline-first/screenshot/Cache1a.jpeg) | ![Cache saat jaringan tersimpan](/05-week-5-local-storage-offline-first/screenshot/cache1b.jpeg) |

| Badge dirty sebelum sinkronisasi | Badge dirty kembali ke 0 setelah koneksi dinyalakan dan `syncNotes` dijalankan | Bukti Mode Pesawat |
| --- | --- | --- |
| ![Badge dirty sebelum sync](/05-week-5-local-storage-offline-first/screenshot/DirtyFlag1b.jpeg) | ![Badge dirty 0 setelah sync](/05-week-5-local-storage-offline-first/screenshot/DirtyFlag1a.jpeg) | ![Bukti mode pesawat](/05-week-5-local-storage-offline-first/screenshot/ModePesawat.jpeg) |


---

## Refactoring Challenge

Tiga refactoring dilakukan dan masing-masing di-commit dengan pesan yang jelas.

Pertama, baris catatan diekstrak menjadi widget `NoteTile` di `lib/widgets/note_tile.dart` yang menampilkan badge "belum tersinkron" bila `dirty == true`. Kedua, logika cache posts dan `syncNotes` dipindahkan ke `lib/data/sync.dart` agar `NoteRepository` fokus pada CRUD saja. Ketiga, ditambahkan halaman detail catatan dengan GoRouter pada rute `/note/:id` yang membaca dari repository lokal, bukan dari state halaman list.

| Tampilan `NoteTile` dengan badge belum tersinkron | Halaman detail catatan melalui rute `/note/:id` |
| --- | --- |
| ![NoteTile dengan badge belum tersinkron](/05-week-5-local-storage-offline-first/screenshot/HalamanDetail1a.jpeg) | ![Halaman detail catatan](/05-week-5-local-storage-offline-first/screenshot/HalamanDetail1b.jpeg) |
---

## AI Prompt Challenge

Prompt yang dipakai, output awal AI, dan tabel perbandingan final disimpan di folder `docs/`. Prompt meminta AI membandingkan `SharedPreferences`, `Hive`, `sqflite`, dan `Drift` berdasarkan kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing, lalu memberi rekomendasi final untuk preferensi dan catatan.

### Tabel Perbandingan Final

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| --- | --- | --- | --- | --- |
| Jenis data | Key-value primitif kecil | NoSQL (box) | Relasional | Relasional |
| Kompleksitas query | Tidak ada query | Terbatas (filter di memori) | SQL penuh | SQL penuh, dengan type-safety |
| Relasi antar data | Tidak mendukung | Manual | Mendukung (JOIN, foreign key) | Mendukung |
| Reaktivitas (stream) | Tidak ada | Ada (`watch` pada box) | Tidak bawaan | Bawaan (`watch()`) |
| Type-safety | Rendah | Sedang (adapter) | Rendah (map mentah) | Tinggi (kode hasil generate) |
| Boilerplate | Sangat sedikit | Sedang | Sedang | Banyak (generator + migrasi) |
| Kemudahan testing | Mudah | Mudah | Mudah dengan injeksi `openDb` | Mudah (database in-memory) |
| Cocok untuk | Preferensi | Cache objek | Catatan + antrean sync | Aplikasi besar dengan query kompleks |

### Keputusan Final

Saya memilih **SharedPreferences untuk preferensi** (tema dan waktu terakhir dibuka) dan **SQLite via sqflite untuk catatan**. Preferensi hanya berupa nilai primitif kecil sehingga key-value sudah cukup. Catatan adalah data koleksi yang membutuhkan query terurut, update parsial, dan kolom `dirty`/`updated_at` untuk antrean sinkronisasi, yang ditangani SQLite dengan baik tanpa boilerplate besar seperti Drift. Kombinasi ini juga paling umum untuk aplikasi offline notes di industri.

### Verifikasi Terhadap Output AI

| Poin verifikasi | Temuan |
| --- | --- |
| Apakah AI menempatkan daftar catatan di SharedPreferences? | Tidak. AI menolak dengan tegas penempatan koleksi (daftar catatan) di SharedPreferences karena rapuh jika data harus terus-menerus di-decode/encode. AI menyarankan SQLite. |
| Apakah skema AI mendukung antrean sync (`dirty` flag / `updated_at`) atau hanya CRUD polos? | Ya. Skema yang disusun memiliki kolom `dirty` (integer 0/1) sebagai penanda antrean sinkronisasi dan kolom `updated_at` untuk menyimpan urutan modifikasi catatan. |
| Apakah klaim "real-time" AI didukung stream (Drift/`watch`) atau hanya asumsi? | Klaim untuk `sqflite` secara eksplisit diakui tidak real-time (tidak ada stream bawaan), sehingga UI disegarkan lewat `ref.invalidate` dari Riverpod. Untuk Drift, AI mencantumkan bahwa stream reaktif (`watch()`) memang didukung penuh. |
| Apakah estimasi boilerplate AI masuk akal setelah dicoba? | Masuk akal. `sqflite` memang butuh sedikit boilerplate manual (`toMap`/`fromMap` dan SQL murni), tetapi tetap lebih sederhana daripada mengonfigurasi generator kode (`build_runner`) sejak awal seperti pada Drift. |


---

## Testing

Pengujian ada di `test/note_test.dart` dengan `FakeNoteRepository` yang mewarisi `NoteRepository` dan meng-override `fetchNotes` serta `countDirty`, sehingga tidak ada akses ke SQLite sungguhan. Empat test yang dijalankan: `fromMap` aman terhadap field yang hilang, flag `dirty` bertahan pada serialisasi, provider sukses dengan repository palsu, dan provider error dengan repository palsu.

| Hasil `flutter analyze` | Hasil `flutter test` |
| --- | --- |
| ![Hasil flutter analyze](/05-week-5-local-storage-offline-first/screenshot/analyze.png) | ![Hasil flutter test](/05-week-5-local-storage-offline-first/screenshot/test.png) |

---

## Kendala dan Solusi

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| `MissingPluginException` | Hot restart setelah menambah plugin tanpa rebuild penuh | Hentikan aplikasi dan jalankan ulang `flutter run` |
| `table notes already exists` | `onCreate` berjalan lagi atau versi database tidak dinaikkan setelah skema berubah | Naikkan `version` + `onUpgrade`, atau uninstall aplikasi saat development |
| Badge dirty tidak pernah nol | `markAllSynced` tidak dipanggil setelah sync sukses | Panggil hanya setelah server menjawab sukses, verifikasi dengan `countDirty` |
| UI tidak refresh setelah tambah catatan | Lupa `ref.invalidate(notesProvider)` | Invalidasi provider setelah mutasi |

## Checklist Verifikasi Mandiri

| Checklist | Status | Keterangan |
| --- | :---: | --- |
| UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider | ✅ | Terpenuhi. Seluruh akses basis data melewati kelas Repository (seperti `NoteRepository` dan `SyncRepository`), lalu disalurkan ke antarmuka menggunakan Riverpod. |
| Aplikasi berfungsi penuh dalam mode pesawat: baca, tambah, hapus catatan | ✅ | Sudah diuji. Catatan yang ditambahkan saat offline berhasil disimpan, dibaca, dan dihapus karena semuanya ditulis langsung ke penyimpanan internal SQLite. |
| Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet | ✅ | Terverifikasi. Badge sinkronisasi (ikon awan jingga) tetap tampil sampai tombol "Sync" dipanggil. Halaman Data API juga memuat dari tabel cache lokal saat gagal menghubungi server atau saat `forceOffline` menyala. |
| `flutter analyze` tanpa issue dan semua test lulus | ✅ | Perintah analisis berhasil dijalankan tanpa masalah lint, dan semua test lulus. |
| Hasil AI diverifikasi dan didokumentasikan di folder `docs/` | ✅ | Selesai. Dokumen analisis storage untuk AI Challenge ada di `docs/ai_challenge.md`. |

## Refleksi

| Pertanyaan | Jawaban |
| --- | --- |
| Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar? | Menyimpan ribuan catatan di SharedPreferences berarti seluruh entri harus diserialisasi menjadi satu JSON besar yang membebani memori setiap kali dibaca atau diperbarui sebagian. Jika terjadi *crash* di tengah proses penyimpanan, seluruh daftar catatan berisiko *corrupt*. |
| Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain? | *Cache-first* (mendahulukan data lokal) cukup untuk membaca artikel, halaman detail profil, atau catatan, karena versi data lama tetap relevan sambil menunggu jaringan. *Network-first* wajib digunakan untuk data yang harus akurat, seperti pembelian barang, saldo dompet digital, atau ketersediaan stok kursi. |
| Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu? | Setiap catatan baru ditandai `dirty` dan langsung disimpan di database lokal, sehingga UI langsung merespons sukses tanpa menunggu jaringan. Di latar belakang, fungsi sinkronisasi mengumpulkan semua catatan `dirty` lalu mengirimnya ke server, dan flag dilepas (*clean*) setelah pengiriman berhasil. Tabel outbox terpisah diperlukan ketika urutan aksi harus dikirim persis berurutan (misalnya ubah lalu hapus saat tidak ada jaringan) agar tidak terjadi tabrakan state. |
| Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa? | Saya menolak semua bagian yang menyimpan objek koleksi di SharedPreferences. Saya juga menghindari Drift pada aplikasi mini ini agar logika pemetaan dasar bisa dipelajari tanpa lapisan ORM, dan menolak Hive karena aplikasi catatan membutuhkan fleksibilitas SQL untuk pengurutan berbasis waktu (`ORDER BY`). |
