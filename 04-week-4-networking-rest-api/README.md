# Mini Project - Networking & REST API

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
1. Pastikan Anda berada di direktori `week4_api`.
2. Jalankan `flutter pub get` untuk mengunduh dependencies.
3. Jalankan `flutter run` untuk meluncurkan aplikasi di emulator atau browser.

## Hasil yang Dicapai
Semua fitur dari Praktikum 1 hingga Praktikum 4 (Refactoring) dan AI Challenge telah diimplementasikan sesuai instruksi modul. Hasil tangkapan layar (termasuk pagination dan error handling) dapat dilihat pada folder `screenshots/`.

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
