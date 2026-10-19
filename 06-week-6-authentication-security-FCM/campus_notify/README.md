# Campus Notify — Authentication, Security & FCM (Minggu 6)

**Nama:** Arifah Zhafirah Wikananda
**NIM:** 244107020188
**Kelas:** 2C — Teknologi Informasi, Politeknik Negeri Malang
**Mata kuliah:** Mobile Development (Flutter)

---

## Tujuan

Campus Notify adalah aplikasi notifikasi akademik sederhana untuk mahasiswa Teknologi Informasi Polinema. Project ini dibuat pada praktikum Minggu 6 untuk mempelajari tiga hal sekaligus: alur autentikasi dengan token yang disimpan aman, arsitektur Firebase Cloud Messaging (FCM), dan penanganan klik notifikasi menuju halaman tertentu lewat deep link. Setelah mengerjakan codelab ini, saya mampu menjelaskan perbedaan access token, refresh token, dan ID token, menyimpan token di secure storage, mengelola siklus hidup token FCM, serta membedakan perilaku notification payload dan data payload pada state foreground, background, dan terminated.

## Fitur Utama

Aplikasi memiliki halaman login dengan validasi input dan pesan kesalahan yang jelas. Setelah login, token disimpan di `flutter_secure_storage` (Keychain/Keystore), bukan di SharedPreferences, dan route dilindungi oleh guard GoRouter sehingga pengguna yang belum login selalu diarahkan ke `/login`. Dio dilengkapi interceptor yang menambahkan header `Authorization: Bearer` pada setiap request, mencoba refresh token satu kali saat menerima respons 401, lalu memaksa login ulang jika refresh gagal.

Di sisi notifikasi, aplikasi meminta izin notifikasi, mengambil token FCM lewat `getToken()`, memantau perubahan token dengan `onTokenRefresh`, dan berlangganan topik `pengumuman-kampus`. Halaman beranda menampilkan status notifikasi (izin, token perangkat yang dipotong, dan status langganan topik), tombol **Salin Token** untuk menempel token di Firebase Console, serta tombol **Tes Tirai HP** untuk menguji banner notifikasi lokal. Daftar pengumuman terbaru dapat dibuka, dan notifikasi yang membawa `data.route` seperti `/pengumuman/3` akan membuka halaman detail pengumuman melalui deep link.

## Stack Teknologi

Flutter dan Dart, `flutter_riverpod` untuk state management, `go_router` untuk navigasi dan deep link, `dio` untuk HTTP client, `flutter_secure_storage` untuk penyimpanan token, serta `firebase_core`, `firebase_messaging`, dan `flutter_local_notifications` untuk FCM dan notifikasi lokal. Autentikasi memakai mock auth provider dengan JWT simulasi agar dapat berjalan tanpa backend, dan titik penggantinya ke Firebase Auth sudah ditandai di `AuthRepository`.

## Struktur Folder

```
06-week-6-authentication-security-fcm/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   ├── auth_repository.dart
│   │   ├── token_store.dart
│   │   └── api_client.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── messaging/
│   │   └── push_service.dart
│   └── pages/
│       ├── login_page.dart
│       ├── home_page.dart
│       └── announcement_page.dart
├── test/
│   └── auth_push_test.dart
├── docs/
├── screenshots/
└── README.md
```

## Cara Menjalankan

1. Pastikan Flutter SDK terpasang, lalu clone repository dan masuk ke folder project:
   ```
   cd 06-week-6-authentication-security-fcm
   ```
2. Pasang dependensi:
   ```
   flutter pub get
   ```
3. Buat project di [Firebase Console](https://console.firebase.google.com/), daftarkan aplikasi Android dengan `applicationId` yang sama, lalu letakkan `google-services.json` di `android/app/`. File ini tidak disertakan di repository karena berisi konfigurasi project.
4. Hubungkan perangkat fisik (disarankan, karena emulator tanpa Google Play Services tidak menghasilkan token FCM) atau emulator yang memiliki ikon Play Store, lalu jalankan:
   ```
   flutter run
   ```
5. Untuk analisis statis dan pengujian:
   ```
   flutter analyze
   flutter test
   ```

---

## Hasil Praktikum

### Praktikum 1 — Autentikasi dan Penyimpanan Token Aman

Pada praktikum ini saya membuat `TokenStore` yang menjadi satu-satunya pintu keluar-masuk token, `AuthRepository` mock yang siap diganti Firebase Auth, serta provider auth dan guard route. Halaman login dimulai dalam keadaan kosong, lalu pengguna mengisi email dan kata sandi.

| Halaman login kosong | Form terisi |
| :---: | :---: |
| ![Halaman login kosong](screenshots/01-login-kosong.png) | ![Form login terisi](screenshots/02-login-terisi.png) |

Validasi input bekerja sebelum request dikirim. Email yang tidak berformat benar langsung ditandai merah dengan pesan "Masukkan email yang valid", sedangkan kredensial yang tidak cocok menghasilkan snackbar "Email atau kata sandi salah".

| Validasi email | Kredensial salah |
| :---: | :---: |
| ![Validasi email tidak valid](screenshots/03-login-validasi-email.png) | ![Email atau kata sandi salah](screenshots/04-login-gagal.png) |

Login yang berhasil menyimpan access token dan refresh token ke secure storage, lalu pengguna diarahkan ke beranda. Pada versi awal beranda, status login ditampilkan beserta tombol menuju pengumuman #3, yang membuka halaman detail pengumuman "Jadwal kuliah berubah".

| Sudah login (versi awal) | Detail pengumuman #3 |
| :---: | :---: |
| ![Anda sudah login](screenshots/05-sudah-login.png) | ![Pengumuman #3](screenshots/06-pengumuman-3.png) |

Tampilan yang sama juga muncul ketika aplikasi dibuka ulang dalam keadaan sudah login, yang membuktikan token masih terbaca dari secure storage setelah aplikasi dimulai kembali.

![Sudah login setelah aplikasi dibuka ulang](screenshots/07-sudah-login-reopen.png)

### Praktikum 2 — Integrasi FCM dan Token Lifecycle

Pada praktikum ini beranda dikembangkan menjadi **Portal Notifikasi Akademik**. Kartu "Status notifikasi" menampilkan izin notifikasi (Diizinkan), token perangkat yang dipotong agar tidak terekspos penuh, dan status topik `pengumuman-kampus` (Berlangganan). Di bawahnya terdapat daftar "Pengumuman terbaru" berisi tiga item: perubahan ruang kuliah Pemrograman Mobile, tenggat laporan praktikum Minggu 6, dan kuliah tamu tentang keamanan dan autentikasi mobile.

| Beranda | Daftar pengumuman (scroll) |
| :---: | :---: |
| ![Beranda Portal Notifikasi Akademik](screenshots/08-beranda.png) | ![Daftar pengumuman terbaru](screenshots/09-beranda-scroll.png) |

Tombol **Salin Token** menyalin token FCM lengkap ke clipboard sehingga dapat ditempel di Firebase Console untuk pengujian kirim pertama. Token penuh tidak ditampilkan di layar maupun di log.

![Token FCM berhasil disalin](screenshots/10-salin-token.png)

### Praktikum 3 — Notifikasi, Deep Link, dan Topic Messaging

Tombol **Tes Tirai HP** mengirim notifikasi lokal untuk memastikan sistem notifikasi perangkat bekerja, dengan umpan balik snackbar "Banner notifikasi dikirim! Periksa tirai notifikasi HP kamu." Banner "Uji Coba Notifikasi Kampus" kemudian benar-benar muncul di tirai notifikasi perangkat.

| Tombol Tes Tirai HP | Banner di tirai notifikasi |
| :---: | :---: |
| ![Banner notifikasi dikirim](screenshots/11-tes-tirai.png) | ![Banner di tirai notifikasi](screenshots/12-banner-tirai.png) |

Notifikasi yang dikirim memakai payload gabungan `notification + data`, dengan `notification` untuk teks yang dibaca manusia dan `data.route` untuk tujuan klik. Ketika notifikasi dengan `route` bernilai `/pengumuman/3` dibuka, aplikasi menavigasi ke halaman detail pengumuman dan menampilkan penanda "Dibuka dari deep link: /pengumuman/3", yang membuktikan rute dari payload diteruskan dengan benar ke GoRouter.

![Halaman pengumuman dibuka dari deep link](screenshots/13-deep-link.png)

### Matriks Pengujian Tiga App State

Payload yang digunakan:

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": { "route": "/pengumuman/3", "id": "3" }
  }
}
```

| App state | Yang diharapkan | Handler | Hasil |
| --- | --- | --- | --- |
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | `onMessage` + local notification | _isi setelah uji_ |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | `onMessageOpenedApp` | _isi setelah uji_ |
| Terminated | Aplikasi terbuka ke rute yang benar | `getInitialMessage` | _isi setelah uji_ |

---

## Prinsip Keamanan yang Diterapkan

Token akses dan refresh hanya disimpan di `flutter_secure_storage`, tidak pernah di SharedPreferences. Tidak ada secret yang di-hardcode di kode Dart, token FCM tidak dicetak penuh ke log maupun ditampilkan penuh di screenshot, dan refresh token hanya dikirim lewat body POST HTTPS, bukan query URL. Handler pesan background dibuat sebagai fungsi top-level dengan `@pragma('vm:entry-point')` karena berjalan di isolate terpisah dan tidak boleh mengakses `BuildContext` maupun Riverpod.

## Pengujian

Unit test pada `test/auth_push_test.dart` menguji logika di sekitar Firebase tanpa memanggil Firebase sungguhan: parsing `RemoteMessage` menjadi route (termasuk route kosong dan tanpa garis miring), pembawaan `id` pengumuman pada data payload, pembacaan status login dari token, dan pembersihan sesi ketika refresh token gagal. Jalankan dengan `flutter test`.

## Dokumentasi AI

Sesuai kebijakan AI pada jobsheet, prompt yang digunakan, output awal AI, daftar perbaikan manual, serta hasil verifikasi checklist disimpan di folder [`docs/`](docs/).

## Refleksi Singkat

Refresh token tidak boleh disimpan di SharedPreferences karena penyimpanan tersebut tidak terenkripsi, sehingga jika bocor penyerang dapat meminta access token baru terus-menerus tanpa perlu kata sandi. Jika `onTokenRefresh` diabaikan, backend akan menyimpan token basi sehingga notifikasi tidak pernah sampai ke perangkat setelah token berotasi. Topik cocok untuk pesan siaran seperti pengumuman seluruh mahasiswa atau satu kelas, sedangkan pesan personal seperti nilai atau tagihan harus dikirim ke token perangkat.

## Referensi

- [Codelab Minggu 6: Authentication, Security & FCM](https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html)
- [FCM Flutter client](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [FCM message types: notification vs data](https://firebase.google.com/docs/cloud-messaging/concept-options)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [GoRouter: redirect & deep linking](https://go_router.dev/)
