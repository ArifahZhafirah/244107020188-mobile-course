# AI Verification Checklist & Dokumentasi Praktikum (Minggu 6)

Dokumen ini disusun untuk memenuhi verifikasi teknis modul Codelab **#06 | Authentication, Security & FCM** bagian **AI Challenge**.

---

## 1. AI Prompt yang Digunakan

```text
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

---

## 2. AI Verification Checklist Table

Berdasarkan ketentuan modul Codelab, berikut adalah checklist verifikasi teknis terhadap kode `PushService` yang telah dibuat:

| No | Poin Verifikasi Modul | Status | Evaluasi & Bukti Teknis pada Kode |
|---|---|:---:|---|
| 1 | **Apakah background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`?** *(Tolak jika berupa method kelas)* | ✅ **VALID** | Fungsi `firebaseMessagingBackgroundHandler` dideklarasikan di tingkat paling atas (top-level), di luar kelas `PushService`, serta dianotasi `@pragma('vm:entry-point')` agar tidak dihapus compiler saat kompilasi AOT/tree-shaking. |
| 2 | **Apakah `onTokenRefresh` benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?** | ✅ **VALID** | Listener `_messaging.onTokenRefresh.listen((newToken) async { await _sendTokenToBackend(newToken); });` aktif memanggil endpoint `POST /devices` via Dio. |
| 3 | **Apakah foreground memakai local notification manual?** *(Tanpa ini banner tidak muncul saat aplikasi terbuka)* | ✅ **VALID** | `FirebaseMessaging.onMessage.listen` memanggil `_localNotifications.show()` dengan konfigurasi channel Android berprioritas tinggi (`Importance.high`, `Priority.high`) dan `DarwinNotificationDetails` untuk iOS. |
| 4 | **Apakah klik dari ketiga state (foreground / background / terminated) masuk ke rute yang benar?** | ✅ **VALID** | Navigasi decoupled dari BuildContext menggunakan `_navigateTo(route)`: <br>• **Foreground:** `onDidReceiveNotificationResponse` <br>• **Background:** `onMessageOpenedApp` <br>• **Terminated:** `getInitialMessage()` dengan fallback `_pendingInitialRoute`. |
| 5 | **Apakah token/secret tidak di-hardcode dan tidak di-log penuh?** | ✅ **VALID** | Token disamarkan menggunakan fungsi `_maskToken(token)` (`substring(0, 12) + '...'`), tidak pernah dicetak utuh ke debug console. Token sensitif disimpan di secure storage (`flutter_secure_storage`). |
| 6 | **Apakah kode bebas dari error kompilasi dan lint?** | ✅ **VALID** | `flutter analyze` menghasilkan **No issues found (0 warnings, 0 errors)** dan seluruh pengujian pada `test/auth_push_test.dart` lulus 100%. |

---

   - Saat aplikasi dalam kondisi terminated, `getInitialMessage()` bisa jadi mengembalikan rute sebelum widget GoRouter selesai terpasang. Oleh karena itu, disediakan mekanisme antrean rute agar deep link tidak hilang (*race condition*).
3. **Penyembunyian Kredensial & Token:**
   - Token disamarkan hanya 12 karakter pertama demi keamanan saat debugging maupun keperluan screenshot laporan praktikum.
4. **Decoupled Router Tanpa BuildContext:**
   - Menghindari runtime error widget ancestor lookup dengan menghubungkan router global melalui handler decoupled.

---

## 6. Checklist Verifikasi Mandiri

- [x] **Token hanya di `flutter_secure_storage`, tidak di SharedPreferences/log/screenshot penuh.**
- [x] **401 memicu refresh sekali lalu retry; refresh mati memaksa login ulang.**
- [x] **Ketiga app state teruji dengan tabel bukti; klik masuk ke rute yang benar.**
- [x] **Topik untuk broadcast, token untuk pesan personal.**
- [x] **`flutter analyze` bersih dan semua test lulus.**

---

## 7. Refleksi Teknis

### 1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?
- `SharedPreferences` menyimpan data dalam format XML plain text tanpa enkripsi di direktori lokal Android. Pada perangkat yang di-*root*, melalui *ADB backup*, atau eksploitasi malware lokal, berkas XML ini dapat diekstrak secara bebas.
- Refresh token memiliki masa hidup panjang (*long-lived*). Bila bocor, penyerang dapat melakukan *session hijacking* dan meminta access token baru kapan saja tanpa memerlukan kata sandi pengguna, mengancam privasi dan data akademik secara terus menerus hingga token dicabut di backend.
- `flutter_secure_storage` mengenkripsi data menggunakan Android Keystore (AES-GCM) dan iOS Keychain Hardware Enclave.

### 2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?
- FCM token secara otomatis dirotasi oleh Google Play Services saat pemulihan perangkat, instal ulang aplikasi, atau rotasi keamanan berkala.
- Jika `onTokenRefresh` diabaikan dan token baru tidak dikirim ke backend (`POST /devices`), database backend memegang *stale token*.
- Seluruh notifikasi kampus penting (jadwal UAS, perubahan kelas mendadak, tagihan UKT) akan mengalami *silent drop* (FCM server menolak pengiriman dengan status `UNREGISTERED`), sehingga mahasiswa tidak menerima kabar akademik penting sepanjang semester.

### 3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.
- **Topik (`topic`):** Pola 1-to-Many (Broadcast). Cocok untuk pesan publik skala massal tanpa membebani backend mengelola jutaan token.
  - *Contoh 1:* "Pengumuman Libur Nasional: Perkuliahan ditiadakan Senin, 20 Oktober."
  - *Contoh 2:* "Jadwal Ujian Akhir Semester Ganjil 2026/2027 telah dirilis."
- **Token Perangkat (`token`):** Pola 1-to-1 (Unicast/Personal). Wajib untuk pesan privat yang memuat informasi sensitif personal.
  - *Contoh 1:* "KRS Anda Semester 5 telah disetujui oleh Dosen Pembimbing Akademik."
  - *Contoh 2:* "Tagihan UKT Anda atas nama Arifah Zhafirah dinyatakan Lunas."

### 4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?
1. **Ditolak:** Inisialisasi FCM via `await` sebelum `runApp()`. *Alasan:* Mengakibatkan black screen saat cold start. *Perbaikan:* `runApp()` dipanggil lebih dulu, FCM diinisialisasi non-blocking di latar belakang.
2. **Ditolak:** Mencetak token FCM mentah penuh ke debug console. *Alasan:* Melanggar standar keamanan data dan privasi. *Perbaikan:* Implementasi fungsi `_maskToken()`.
3. **Ditolak:** Mengakses `BuildContext` di dalam event listener FCM untuk navigasi. *Alasan:* Rawan memicu error runtime unmounted context. *Perbaikan:* Menggunakan callback router global.
4. **Ditolak:** Navigasi terminated langsung tanpa buffer antrean rute. *Alasan:* Rawan race condition jika router belum siap saat cold boot. *Perbaikan:* Menyediakan antrean `_pendingInitialRoute`.

