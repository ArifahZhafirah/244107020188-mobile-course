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
