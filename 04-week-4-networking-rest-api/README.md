# 04 | Networking & REST API

## Tujuan
Memahami konsep HTTP, REST API, dan JSON. Mengimplementasikan Repository Pattern dan State Management menggunakan Riverpod untuk menangani *Loading*, *Error*, *Empty*, dan *Success* states, serta pagination.

## Fitur Utama
- **Get Posts List**: Menampilkan daftar post dari JSONPlaceholder menggunakan infinite scroll (pagination).
- **Post Detail**: Halaman detail post menggunakan GoRouter.
- **Error Handling**: Penanganan kesalahan yang ramah pengguna, baik karena masalah jaringan, timeout, atau server.
- **AI Challenge**: Implementasi endpoint `GET /comments` yang dilengkapi dengan null-safety data mapping dan unit tests.

## Stack Teknologi
- **Flutter**
- **Dio** (HTTP Client)
- **Riverpod** (State Management)
- **GoRouter** (Routing)

## Cara Menjalankan
1. Masuk ke dalam direktori aplikasi: `cd week4_api`
2. Unduh dependencies: `flutter pub get`
3. Jalankan aplikasi: `flutter run`

---

## Hasil Praktikum & Screenshots

### 1. Tampilan Awal & Paged List
Tampilan saat aplikasi baru dijalankan dan menampilkan halaman pertama list post. (Sudah di-refactor menggunakan `PostTile`).
![Tampilan Awal](screenshots/5_Paged_PostTile.png)

### 2. Indikator Loading Pagination
Tampilan saat men-scroll ke bawah dan indikator loading muncul sebelum memuat post tambahan.
![Indikator Loading](screenshots/2_indikator_loading.png)

### 3. Semua Data Termuat
Tampilan saat data post sudah dimuat semuanya sampai ujung akhir list.
![Semua Data Termuat](screenshots/3_semua_data_termuat.png)

### 4. Detail Post (GoRouter)
Tampilan saat salah satu post di klik, aplikasi menavigasikan halaman menggunakan GoRouter.
![Detail Post](screenshots/5_Detail_Post.png)

### 5. Hasil Unit Testing (Termasuk AI Challenge & Refactoring)
Berikut adalah bukti berjalannya pengujian (Test) pada model (Null Safety Edge Case), error mapping, dan mock repository.

**Test AI Challenge (Comments):**
![Test AI Challenge](screenshots/4_AI_challenge_test.png)

**Test Refactoring (Posts):**
![Test Refactoring](screenshots/5_Refactoring_test.png)

---

## Refleksi

1. **Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?**
   UI bertugas murni untuk merender tampilan visual (Presentation Layer). Jika UI memanggil Dio secara langsung, kode jaringan akan tersebar di berbagai Widget, sehingga menyulitkan *reusability* (penggunaan ulang), membuat penanganan error tidak konsisten, dan membuat komponen UI menjadi mustahil untuk di-*unit test* dengan aman menggunakan *mocking*.

2. **Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (`_page`/`_limit`)?**
   Pagination client-side cukup jika total data yang ditarik jumlahnya terukur dan statis (misalnya, list kategori aplikasi). Kita butuh pagination dari server jika data berjumlah sangat besar dan dinamis, agar tidak membebani memori HP (*Out Of Memory*) serta menghemat pemakaian paket internet pengguna.

3. **Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?**
   Di dalam Riverpod `AsyncNotifier`, exception apa pun yang di-*throw* (dilempar) oleh fungsi `build()` akan ditangkap secara otomatis secara internal oleh Riverpod, yang lalu mengubah *state* menjadi `AsyncError`. Try/catch eksplisit tetap dibutuhkan ketika kita melakukan panggilan fungsi asinkron secara manual akibat respon dari interaksi pengguna (misal: saat fungsi dari tombol refresh dijalankan atau memuat halaman berikutnya via *scroll*).

4. **Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**
   Saya harus memastikan model hasil respon AI tetap mematuhi pola *defensive null-safety* (contoh: `(json['id'] as num?)?.toInt() ?? 0` atau `as String? ?? ''`). Tanpa *defensive casting*, aplikasi berisiko mendadak *crash* (*Null Check Operator Error*) apabila struktur respon API yang kembali kehilangan salah satu *field*.
