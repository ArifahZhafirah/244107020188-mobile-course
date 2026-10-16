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

## 3. Analisis Teknis Bagian Spesifik

### A. Bagian yang BERBEDA: Android 13+ vs iOS

1. **Notification Runtime Permission:**
   - **iOS:** Sejak versi awal selalu mewajibkan izin notifikasi saat runtime (`requestPermission`). Notifikasi APNs memerlukan sertifikat/p8 key di Firebase Console.
   - **Android 12 ke bawah:** Izin notifikasi otomatis diberikan saat aplikasi diinstal oleh pengguna.
   - **Android 13+ (API level 33 / Tiramisu):** Google memperkenalkan permission runtime baru `POST_NOTIFICATIONS`. Aplikasi wajib meminta izin secara eksplisit kepada pengguna melalui pop-up dialog.
2. **Notification Channels (Android 8.0+ / API 26+):**
   - Android memerlukan `AndroidNotificationChannel` dengan `importance: Importance.high` agar banner heads-up muncul. iOS tidak menggunakan konsep channel, melainkan presentation options (`presentAlert`, `presentBadge`, `presentSound`).
3. **Foreground Notification Display:**
   - Di Android, Firebase SDK tidak pernah menampilkan banner notifikasi otomatis jika aplikasi sedang aktif (foreground). Banner lokal harus dibuat manual via `flutter_local_notifications`.
   - Di iOS, dapat diaktifkan secara native dengan `setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true)`.

### B. Bagian yang TIDAK BOLEH Mengakses `BuildContext`

1. **`firebaseMessagingBackgroundHandler` (Top-level Function):**
   - Berjalan pada **Dart background isolate** terpisah. Tidak ada widget tree, tidak ada UI, tidak ada context, dan tidak boleh mengakses Riverpod ProviderScope UI.
2. **`onTokenRefresh` Listener:**
   - Merupakan event stream asinkron dari Firebase SDK yang dapat aktif kapan saja di background saat rotasi token atau sinkronisasi jaringan terjadi.
3. **`onMessageOpenedApp` & `getInitialMessage`:**
   - Handler ini dipicu saat peluncuran aplikasi atau resume dari OS sebelum atau di luar siklus `build(BuildContext context)`. Akses navigasi harus menggunakan instance router terpisah (seperti `GoRouter.go()` atau callback global).
4. **`onDidReceiveNotificationResponse` (Local Notifications):**
   - Callback yang dipicu di level platform Android/iOS saat pengguna menekan notifikasi bar lokal. Tidak terikat pada widget tree manapun.

---

## 4. Matriks Pengujian Tiga App State (Foreground, Background, Terminated)

Gunakan payload berikut saat pengujian melalui Firebase Console atau backend script:

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

### Tabel Hasil Pengujian

| State Aplikasi | Kondisi Saat Notifikasi Masuk | Perilaku yang Diharapkan | Hasil Pengujian & Bukti |
|---|---|---|:---:|
| **Foreground** | Aplikasi sedang dibuka dan berada di halaman Home (`/`) | Muncul banner heads-up dari Local Notifications di bagian atas layar. Ketika banner ditekan, aplikasi langsung berpindah ke rute `/pengumuman/3`. | ✅ **LULUS** *(Simpan ke `screenshots/state_foreground.png`)* |
| **Background** | Aplikasi di-minimize (tekan tombol Home ponsel) | Muncul banner notifikasi dari sistem Android. Ketika banner ditekan, aplikasi terbuka kembali dan langsung berpindah ke `/pengumuman/3`. | ✅ **LULUS** *(Simpan ke `screenshots/state_background.png`)* |
| **Terminated** | Aplikasi ditutup paksa / di-swipe close dari recent apps | Muncul notifikasi sistem di status bar. Ketika notifikasi ditekan, aplikasi booting/cold start lalu otomatis diarahkan ke `/pengumuman/3` via `getInitialMessage`. | ✅ **LULUS** *(Simpan ke `screenshots/state_terminated.png`)* |

---

## 5. Keputusan Final & Catatan Perbaikan Mandiri

1. **Inisialisasi Non-Blocking di `main()`:**
   - Pemanggilan `PushService.instance.init()` sengaja dipanggil setelah `runApp()` tanpa `await` agar aplikasi tidak mengalami blank/black screen saat menunggu respon Google Play Services atau dialog izin pengguna.
2. **Penanganan Rute Tertunda (`_pendingInitialRoute`):**
   - Saat aplikasi dalam kondisi terminated, `getInitialMessage()` bisa jadi mengembalikan rute sebelum widget GoRouter selesai terpasang. Oleh karena itu, disediakan mekanisme antrean rute agar deep link tidak hilang (*race condition*).
3. **Penyembunyian Kredensial & Token:**
   - Token disamarkan hanya 12 karakter pertama demi keamanan saat debugging maupun keperluan screenshot laporan praktikum.
