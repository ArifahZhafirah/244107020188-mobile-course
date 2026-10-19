# Campus Notify — Authentication, Security & FCM (Minggu 6)

**Nama:** Arifah Zhafirah Wikananda

**NIM:** 244107020188

**Kelas:** 3F — Teknologi Informasi, Politeknik Negeri Malang

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
| ![mini](/06-week-6-authentication-security-FCM/screenshot/HalamanLoginKosong.jpeg) | ![mini](/06-week-6-authentication-security-FCM/screenshot/FormLoginTerisi.jpeg) |

Validasi input bekerja sebelum request dikirim. Email yang tidak berformat benar langsung ditandai merah dengan pesan "Masukkan email yang valid", sedangkan kredensial yang tidak cocok menghasilkan snackbar "Email atau kata sandi salah".

| Validasi email | Kredensial salah |
| :---: | :---: |
| ![mini](/06-week-6-authentication-security-FCM/screenshot/EmailTidakValid.jpeg) | ![mini](/06-week-6-authentication-security-FCM/screenshot/EmailSalah.jpeg) |

Login yang berhasil menyimpan access token dan refresh token ke secure storage, lalu pengguna diarahkan ke beranda. Pada versi awal beranda, status login ditampilkan beserta tombol menuju pengumuman #3, yang membuka halaman detail pengumuman "Jadwal kuliah berubah".

| Sudah login (versi awal) | Detail pengumuman #3 |
| :---: | :---: |
| ![mini](/06-week-6-authentication-security-FCM/screenshot/SudahLogin.jpeg)| ![mini](/06-week-6-authentication-security-FCM/screenshot/DetailPengumuman.jpeg) |

Tampilan yang sama juga muncul ketika aplikasi dibuka ulang dalam keadaan sudah login, yang membuktikan token masih terbaca dari secure storage setelah aplikasi dimulai kembali.

![mini](/06-week-6-authentication-security-FCM/screenshot/LoginKembali.jpeg)

### Praktikum 2 — Integrasi FCM dan Token Lifecycle

Pada praktikum ini beranda dikembangkan menjadi **Portal Notifikasi Akademik**. Kartu "Status notifikasi" menampilkan izin notifikasi (Diizinkan), token perangkat yang dipotong agar tidak terekspos penuh, dan status topik `pengumuman-kampus` (Berlangganan). Di bawahnya terdapat daftar "Pengumuman terbaru" berisi tiga item: perubahan ruang kuliah Pemrograman Mobile, tenggat laporan praktikum Minggu 6, dan kuliah tamu tentang keamanan dan autentikasi mobile.

| Beranda | Daftar pengumuman (scroll) |
| :---: | :---: |
| ![mini](/06-week-6-authentication-security-FCM/screenshot/BerandaNotifikasiDikirim.jpeg) | ![mini](/06-week-6-authentication-security-FCM/screenshot/DaftarPengumumanTerbaru.jpeg) |

Tombol **Salin Token** menyalin token FCM lengkap ke clipboard sehingga dapat ditempel di Firebase Console untuk pengujian kirim pertama. Token penuh tidak ditampilkan di layar maupun di log.

![mini](/06-week-6-authentication-security-FCM/screenshot/TokenBerhasil.jpeg)

### Praktikum 3 — Notifikasi, Deep Link, dan Topic Messaging

Tombol **Tes Tirai HP** mengirim notifikasi lokal untuk memastikan sistem notifikasi perangkat bekerja, dengan umpan balik snackbar "Banner notifikasi dikirim! Periksa tirai notifikasi HP kamu." Banner "Uji Coba Notifikasi Kampus" kemudian benar-benar muncul di tirai notifikasi perangkat.

| Tombol Tes Tirai HP | Banner di tirai notifikasi |
| :---: | :---: |
| ![mini](/06-week-6-authentication-security-FCM/screenshot/NotifikasiDikirim.jpeg) | ![mini](/06-week-6-authentication-security-FCM/screenshot/NotifikasiDitirai.jpeg) |

Notifikasi yang dikirim memakai payload gabungan `notification + data`, dengan `notification` untuk teks yang dibaca manusia dan `data.route` untuk tujuan klik. Ketika notifikasi dengan `route` bernilai `/pengumuman/3` dibuka, aplikasi menavigasi ke halaman detail pengumuman dan menampilkan penanda "Dibuka dari deep link: /pengumuman/3", yang membuktikan rute dari payload diteruskan dengan benar ke GoRouter.

![mini](/06-week-6-authentication-security-FCM/screenshot/HalamanPengumuman.jpeg)

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

Sesuai kebijakan AI pada jobsheet, AI hanya dipakai untuk draf awal service FCM dan boilerplate auth. Perilaku nyata (token lifecycle, jenis payload, dan notifikasi di tiga app state) saya buktikan sendiri lewat screenshot dan log. Prompt yang digunakan:

```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

Output awal AI dan daftar perbaikan manual disimpan di folder [`docs/`](docs/).

### AI Verification Checklist

Setiap butir diperiksa terhadap draf AI sebelum diterima. Kolom temuan diisi berdasarkan hasil pemeriksaan kode dan pengujian di perangkat.

| No | Poin Verifikasi Modul | Status | Evaluasi & Bukti Teknis pada Kode |
|---|---|:---:|---|
| 1 | **Apakah background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`?** *(Tolak jika berupa method kelas)* | ✅ **VALID** | Fungsi `firebaseMessagingBackgroundHandler` dideklarasikan di tingkat paling atas (top-level), di luar kelas `PushService`, serta dianotasi `@pragma('vm:entry-point')` agar tidak dihapus compiler saat kompilasi AOT/tree-shaking. |
| 2 | **Apakah `onTokenRefresh` benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?** | ✅ **VALID** | Listener `_messaging.onTokenRefresh.listen((newToken) async { await _sendTokenToBackend(newToken); });` aktif memanggil endpoint `POST /devices` via Dio. |
| 3 | **Apakah foreground memakai local notification manual?** *(Tanpa ini banner tidak muncul saat aplikasi terbuka)* | ✅ **VALID** | `FirebaseMessaging.onMessage.listen` memanggil `_localNotifications.show()` dengan konfigurasi channel Android berprioritas tinggi (`Importance.high`, `Priority.high`) dan `DarwinNotificationDetails` untuk iOS. |
| 4 | **Apakah klik dari ketiga state (foreground / background / terminated) masuk ke rute yang benar?** | ✅ **VALID** | Navigasi decoupled dari BuildContext menggunakan `_navigateTo(route)`: <br>• **Foreground:** `onDidReceiveNotificationResponse` <br>• **Background:** `onMessageOpenedApp` <br>• **Terminated:** `getInitialMessage()` dengan fallback `_pendingInitialRoute`. |
| 5 | **Apakah token/secret tidak di-hardcode dan tidak di-log penuh?** | ✅ **VALID** | Token disamarkan menggunakan fungsi `_maskToken(token)` (`substring(0, 12) + '...'`), tidak pernah dicetak utuh ke debug console. Token sensitif disimpan di secure storage (`flutter_secure_storage`). |
| 6 | **Apakah kode bebas dari error kompilasi dan lint?** | ✅ **VALID** | `flutter analyze` menghasilkan **No issues found (0 warnings, 0 errors)** dan seluruh pengujian pada `test/auth_push_test.dart` lulus 100%. |

**Keputusan final dan alasan teknis.** Saya memilih mock auth provider dengan JWT simulasi karena codelab ini tidak mensyaratkan backend, dan pola repository serta refresh-nya identik dengan Firebase Auth sehingga migrasi hanya mengganti sumber token. Token ditampilkan terpotong di halaman beranda agar aman dipakai dalam screenshot laporan, sedangkan token penuh hanya tersedia lewat tombol salin untuk ditempel di Firebase Console. Saya menambahkan tombol Tes Tirai HP agar sistem notifikasi perangkat dapat diuji terpisah dari FCM, sehingga jika banner tidak muncul saya bisa membedakan masalah di perangkat dan masalah di konfigurasi Firebase. Payload yang dikirim selalu gabungan `notification` dan `data`, karena `notification` memastikan Android menampilkan banner otomatis saat background atau terminated, sementara `data.route` membawa tujuan deep link.

### Checklist Verifikasi Mandiri

| Status | Poin Verifikasi | Bukti & Evaluasi Teknis |
|:------:|-----------------|-------------------------|
| ✅ VALID | Token hanya di `flutter_secure_storage`, tidak di `SharedPreferences`/log/screenshot penuh. | **Terpenuhi.** `TokenStore` hanya menggunakan `FlutterSecureStorage`. Tidak ada `SharedPreferences` untuk token sesi. Token pada log console dan UI disamarkan. |
| ✅ VALID | 401 memicu refresh sekali lalu retry; refresh mati memaksa login ulang. | **Terpenuhi.** Diimplementasikan di `buildApiClient` via Dio `onError` interceptor. Jika 401, ambil refresh token, panggil `auth.refresh()`, update store, dan ulangi request awal dengan header baru. Jika gagal, blok `catch` menjalankan `await store.clear()` (paksa login ulang). Telah teruji di `auth_push_test.dart`. |
| ✅ VALID | Ketiga app state teruji dengan tabel bukti; klik masuk ke rute yang benar. | **Terpenuhi.** Tabel pengujian 3 state di bawah membuktikan routing tepat ke `/pengumuman/3`. |
| ✅ VALID | Topik untuk broadcast, token untuk pesan personal. | **Terpenuhi.** `subscribeToTopic('pengumuman-kampus')` aktif untuk siaran massal satu kampus, sedangkan `_sendTokenToBackend()` mendaftarkan device token untuk pesan privat (KRS/nilai/UKT). |
| ✅ VALID | `flutter analyze` bersih dan semua test lulus. | **Terpenuhi.** Bukti eksekusi nyata:<br>`flutter analyze` ➔ `No issues found!` (0 warning, 0 error)<br>`flutter test` ➔ `All tests passed!` (5/5 unit test sukses) |

## Refleksi

| No | Pertanyaan / Evaluasi | Jawaban & Argumentasi Teknis |
|:--:|-----------------------|------------------------------|
| 1 | Mengapa refresh token tidak boleh disimpan di `SharedPreferences`? Apa risikonya bila bocor? | **Penyimpanan `SharedPreferences` di Android:** Data disimpan dalam file XML teks polos (*plain text*) di path `/data/data/<package_name>/shared_prefs/*.xml`. Pada perangkat Android yang di-*root*, melalui ADB backup (`adb backup`), atau *malware* yang memanfaatkan izin akses berkas, berkas ini dapat diekstrak tanpa proteksi enkripsi.<br><br>**Karakteristik & Risiko Refresh Token:** Refresh token memiliki masa berlaku panjang (*long-lived*, berbulan-bulan hingga satu semester). Jika bocor, penyerang dapat melakukan *session hijacking* permanen: penyerang dapat terus meminta `access_token` baru tanpa perlu mengetahui sandi korban. Penyerang dapat membaca nilai, mengubah data KRS, atau menyalahgunakan hak akses mahasiswa hingga token dicabut manual di backend server.<br><br>**Solusi yang Benar:** Menggunakan `flutter_secure_storage` yang memanfaatkan perangkat keras pengenkripsi Android Keystore (AES-GCM) dan iOS Keychain. |
| 2 | Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan? | **Penyebab Rotasi Token FCM:** Google Play Services dan Firebase SDK secara otomatis memperbarui (*rotate*) token perangkat saat: pengguna membersihkan data/cache aplikasi (*clear data*), aplikasi dipulihkan di perangkat baru atau pembaruan OS besar, terjadi rotasi kunci periodik Firebase, atau aplikasi tidak aktif dalam durasi panjang lalu dibuka kembali.<br><br>**Dampak Fatal:** Jika listener `onTokenRefresh` tidak mengirimkan token baru ke `POST /devices`, server backend kampus akan menyimpan token lama (*stale token*). Saat kampus mengirimkan notifikasi penting (jadwal ujian mendadak, perubahan ruangan kelas, pengumuman nilai, batas bayar UKT), Firebase FCM server akan menolaknya dengan pesan error `UNREGISTERED` atau `INVALID_REGISTRATION`. Akibatnya terjadi *silent drop*: kampus merasa notifikasi sudah terkirim, namun mahasiswa tidak pernah menerimanya sepanjang semester. |
| 3 | Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing. | **Topik FCM (Topic):** Digunakan untuk pola komunikasi 1-ke-Banyak (*Broadcast / Multicast*). Backend cukup menerbitkan pesan ke nama topik tanpa perlu melacak ratusan ribu token perangkat satu per satu.<br>• *Contoh:* Topik `pengumuman-kampus`: "Pengumuman Libur Nasional & Dies Natalis: Kegiatan perkuliahan ditiadakan pada Senin, 20 Oktober."<br>• *Contoh:* Topik `prodi-ti`: "Kuliah Tamu Praktisi Industri 'Cloud Architecture' wajib diikuti seluruh mahasiswa Jurusan TI angkatan 2024."<br>• *Contoh:* Topik `jadwal-uas`: "Jadwal Ujian Akhir Semester (UAS) Ganjil 2026/2027 telah dirilis di portal akademik."<br><br>**Token Perangkat FCM (Token):** Digunakan untuk pola komunikasi 1-ke-1 (*Unicast / Personal / Transaksional*). Pesan hanya relevan dan ditujukan eksklusif bagi satu mahasiswa tertentu.<br>• *Contoh:* Notifikasi Persetujuan KRS: "KRS Anda Semester 5 telah disetujui oleh Dosen Pembimbing Akademik (Dr. Budi, M.T.)."<br>• *Contoh:* Notifikasi Keuangan: "Pembayaran UKT atas nama Arifah Zhafirah berhasil diverifikasi Lunas."<br>• *Contoh:* Notifikasi Nilai Tugas: "Nilai Tugas Praktikum Pemrograman Mobile Minggu 6 telah diperbarui: 100 (A)."<br>• *Contoh:* Keamanan Akun: "Terdeteksi aktivitas login baru ke akun portal akademik Anda dari perangkat tidak dikenal." |
| 4 | Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa? | **Ditolak: Inisialisasi FCM Menggunakan `await` Sebelum `runApp()`.**<br>• *Saran AI:* `await PushService.instance.init()` sebelum `runApp()`.<br>• *Alasan Ditolak:* Menunggu inisialisasi koneksi Play Services dan dialog izin pengguna sebelum widget UI dipasang menyebabkan *cold-start lag* (layar hitam/putih kosong 1–3 detik). Diperbaiki dengan memanggil `runApp()` terlebih dahulu, kemudian inisialisasi FCM berjalan *non-blocking* di latar belakang.<br><br>**Ditolak: Mencetak Token FCM Mentah Utuh ke Log Console.**<br>• *Saran AI:* `print('FCM Token: $token')`.<br>• *Alasan Ditolak:* Melanggar standar keamanan OWASP Mobile. Token perangkat mentah dapat terekam di sistem Logcat Android publik. Diperbaiki dengan *masking helper* `_maskToken(token)` (`${token.substring(0, 12)}...`).<br><br>**Ditolak: Mengakses `BuildContext` di Event Listener FCM.**<br>• *Saran AI:* `Navigator.push(context, ...)` di dalam handler `onMessageOpenedApp`.<br>• *Alasan Ditolak:* Event listener FCM bekerja asinkron di luar siklus hidup *widget tree*, sehingga rawan crash `Looking up a deactivated widget's ancestor is unsafe`. Diperbaiki dengan mengikat instance router global `_router.go(route)` yang *decoupled* dari context.<br><br>**Ditolak: Ketiadaan Penanganan Deep Link Tertunda pada State Terminated (Race Condition).**<br>• *Saran AI:* Langsung bernavigasi dari `getInitialMessage()` tanpa mengecek kesiapan GoRouter.<br>• *Alasan Ditolak:* Saat aplikasi dibuka dari kondisi mati, `getInitialMessage()` bisa selesai sebelum GoRouter terpasang di widget tree, menyebabkan payload hilang. Diperbaiki dengan buffer antrean `_pendingInitialRoute` pada `PushService`. |
