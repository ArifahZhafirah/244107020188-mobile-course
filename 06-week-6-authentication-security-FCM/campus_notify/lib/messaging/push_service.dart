import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

// =============================================================================
// [TIDAK BOLEH MENGAKSES BUILDCONTEXT]
// Handler background WAJIB berupa top-level function (bukan method dalam class)
// dan harus dianotasi @pragma('vm:entry-point') agar tidak di-tree-shake oleh compiler.
//
// Alasan tidak boleh BuildContext:
// Fungsi ini dieksekusi di Dart isolate terpisah saat aplikasi di-background atau
// dalam kondisi terminated. Pada isolate ini, TIDAK ADA widget tree, UI, maupun
// BuildContext. Handler ini hanya untuk tugas ringan (e.g., simpan data/analytics).
// =============================================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM-Background] Pesan masuk di background isolate: ${message.messageId}');
  debugPrint('[FCM-Background] Payload data: ${message.data}');
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Dio? _dio;
  void Function(String route)? _navigateHandler;
  String? _pendingInitialRoute;

  // Channel notifikasi khusus Android (Wajib untuk Android 8.0+ / API 26+)
  static const AndroidNotificationChannel _campusChannel =
      AndroidNotificationChannel(
    'pengumuman_kampus',
    'Pengumuman Kampus',
    description: 'Channel resmi untuk pengumuman perkuliahan dan akademik',
    importance: Importance.high,
  );

  /// Inisialisasi PushService lengkap.
  /// Panggil di `main()` setelah `runApp()` atau `WidgetsFlutterBinding.ensureInitialized()`.
  Future<void> init({
    Dio? apiClient,
    void Function(String route)? onNavigate,
  }) async {
    _dio = apiClient ??
        Dio(
          BaseOptions(
            baseUrl: 'https://example-campus-api.test',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

    if (onNavigate != null) {
      setNavigationHandler(onNavigate);
    }

    // 1. Daftarkan background handler top-level
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Setup Flutter Local Notifications untuk foreground banner
    await _initLocalNotifications();

    // 3. Minta izin notifikasi (Android 13+ vs iOS)
    await requestNotificationPermission();

    // 4. Token lifecycle: ambil token & monitor perubahannya (kirim ke backend)
    await _initTokenLifecycle();

    // 5. Setup handler pesan foreground, background, dan terminated
    await _setupMessageHandlers();

    // 6. Langganan topik pengumuman kampus default
    await subscribeToTopic('pengumuman-kampus');
  }

  /// Menghubungkan fungsi navigasi (mis. GoRouter) ke PushService
  /// tanpa memerlukan BuildContext langsung di dalam event listener.
  void setNavigationHandler(void Function(String route) handler) {
    _navigateHandler = handler;
    // Jika ada rute dari initialMessage saat terminated yang tertunda, eksekusi sekarang
    if (_pendingInitialRoute != null) {
      final route = _pendingInitialRoute!;
      _pendingInitialRoute = null;
      debugPrint('[FCM-Nav] Mengeksekusi rute tertunda: $route');
      handler(route);
    }
  }

  // ===========================================================================
  // [BAGIAN BERBEDA: ANDROID 13+ VS IOS]
  // 1. iOS: Runtime permission selalu wajib sejak dulu. Konfigurasi mencakup
  //    alert, badge, sound, carPlay, dll. Membutuhkan sertifikat APNs di backend.
  // 2. Android 12 ke bawah: Permission granted secara otomatis saat instalasi.
  // 3. Android 13+ (API 33+ / TIRAMISU): Google mewajibkan izin POST_NOTIFICATIONS
  //    secara runtime seperti iOS. Diatur oleh FirebaseMessaging.instance.requestPermission.
  // ===========================================================================
  Future<bool> requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // [iOS Spesifik]: Mengatur opsi presentasi saat aplikasi di foreground
    // agar banner APNs tetap dapat ditampilkan langsung jika diinginkan.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('[FCM-Permission] Status otorisasi: ${settings.authorizationStatus}');
    return isGranted;
  }

  /// Mengecek apakah izin notifikasi aktif saat ini
  Future<bool> isPermissionGranted() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Mengambil token perangkat asli (tanpa masking) untuk keperluan uji coba Firebase Console
  Future<String?> getRawToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Mengambil token perangkat dalam format terpotong (masked) untuk tampilan UI/Debug
  Future<String?> getMaskedToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return null;
      return _maskToken(token);
    } catch (_) {
      return null;
    }
  }

  /// Memunculkan notifikasi uji coba langsung untuk memvalidasi channel dan izin di tirai HP
  Future<void> showTestNotification() async {
    final androidDetails = AndroidNotificationDetails(
      _campusChannel.id,
      _campusChannel.name,
      channelDescription: _campusChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      id: 999,
      title: 'Uji Coba Notifikasi Kampus',
      body: 'Jika banner ini muncul di tirai, sistem notifikasi di HP kamu sudah 100% aktif!',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: '/pengumuman/3',
    );
  }

  /// Inisialisasi konfigurasi Local Notifications untuk foreground banner.
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // [iOS Spesifik]: Pengaturan inisialisasi Darwin / iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // =====================================================================
        // [TIDAK BOLEH MENGAKSES BUILDCONTEXT]
        // Callback response klik banner lokal dipicu dari level OS.
        // Tidak ada BuildContext yang valid di sini. Navigasi diteruskan
        // melalui callback `_navigateHandler` (GoRouter).
        // =====================================================================
        final payload = response.payload;
        debugPrint('[FCM-Local] Banner lokal diklik, payload: $payload');
        if (payload != null && payload.isNotEmpty) {
          _navigateTo(payload);
        }
      },
    );

    // [Android Spesifik]: Android 8.0+ (API 26+) mewajibkan channel sebelum menampilkan notifikasi
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_campusChannel);
  }

  /// Token lifecycle: Ambil token registrasi dan dengarkan pembaruan (refresh).
  Future<void> _initTokenLifecycle() async {
    // 1. Ambil registration token saat ini
    final token = await _messaging.getToken();
    if (token != null) {
      // Keamanan: JANGAN mencetak token penuh di log production
      debugPrint('[FCM-Token] Token aktif (masked): ${_maskToken(token)}');
      await _sendTokenToBackend(token);
    }

    // =========================================================================
    // [TIDAK BOLEH MENGAKSES BUILDCONTEXT]
    // Stream listener `onTokenRefresh` dapat terpicu kapan saja di background
    // (misal rotasi token keamanan, reinstall, atau update Firebase SDK).
    // Stream ini murni untuk urusan sinkronisasi data/network ke backend.
    // =========================================================================
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM-Token] Token di-refresh (masked): ${_maskToken(newToken)}');
      await _sendTokenToBackend(newToken);
    });
  }

  /// Mengirim token FCM ke server kampus via POST /devices.
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final platform = defaultTargetPlatform == TargetPlatform.android
          ? 'android'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'other';

      await _dio?.post(
        '/devices',
        data: {
          'fcm_token': token,
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('[FCM-Backend] Berhasil kirim token ke endpoint POST /devices');
    } catch (e) {
      // Pada lingkungan testing/offline mock backend, kita catat kegagalan tanpa crash
      debugPrint('[FCM-Backend] Gagal kirim token ke POST /devices (Mock/Offline): $e');
    }
  }

  /// Menyiapkan listener pesan pada 3 state aplikasi (Foreground, Background, Terminated).
  Future<void> _setupMessageHandlers() async {
    // -------------------------------------------------------------------------
    // 1. STATE FOREGROUND: Aplikasi sedang aktif dibuka
    // Sistem Android TIDAK memunculkan banner notifikasi otomatis di foreground.
    // Kita harus menampilkan local notification secara manual.
    // -------------------------------------------------------------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('[FCM-Foreground] Pesan diterima saat app aktif: ${message.messageId}');

      final notification = message.notification;
      final route = routeFromMessage(message.data);

      // Tampilkan banner manual menggunakan flutter_local_notifications
      final androidDetails = AndroidNotificationDetails(
        _campusChannel.id,
        _campusChannel.name,
        channelDescription: _campusChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: message.hashCode,
        title: notification?.title ?? 'Pengumuman Kampus',
        body: notification?.body ?? 'Ketuk untuk membaca pengumuman baru',
        notificationDetails: details,
        payload: route,
      );
    });

    // -------------------------------------------------------------------------
    // 2. STATE BACKGROUND: Aplikasi diminimize / di background
    // [TIDAK BOLEH MENGAKSES BUILDCONTEXT]
    // Banner notifikasi dimunculkan otomatis oleh sistem. Saat banner diklik,
    // listener ini terpicu. Navigasi dilakukan melalui callback GoRouter.
    // -------------------------------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM-Background-Click] Banner notifikasi diklik dari background');
      final route = routeFromMessage(message.data);
      _navigateTo(route);
    });

    // -------------------------------------------------------------------------
    // 3. STATE TERMINATED: Aplikasi dalam kondisi mati total (swiped away)
    // [TIDAK BOLEH MENGAKSES BUILDCONTEXT]
    // Saat user mengklik banner notifikasi saat aplikasi mati, aplikasi dibuka
    // dan payload pesan diambil melalui `getInitialMessage()`.
    // -------------------------------------------------------------------------
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM-Terminated-Click] Aplikasi dibuka dari terminated via notifikasi');
      final route = routeFromMessage(initialMessage.data);
      _navigateTo(route);
    }
  }

  /// Berlangganan topik notifikasi (Broadcast untuk seluruh mahasiswa/kampus).
  Future<void> subscribeToTopic([String topic = 'pengumuman-kampus']) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[FCM-Topic] Berhasil subscribe ke topic: $topic');
    } catch (e) {
      debugPrint('[FCM-Topic] Gagal subscribe ke topic $topic: $e');
    }
  }

  /// Berhenti berlangganan dari topik notifikasi.
  Future<void> unsubscribeFromTopic([String topic = 'pengumuman-kampus']) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[FCM-Topic] Berhasil unsubscribe dari topic: $topic');
    } catch (e) {
      debugPrint('[FCM-Topic] Gagal unsubscribe dari topic $topic: $e');
    }
  }

  /// Menjalankan navigasi secara aman tanpa BuildContext.
  void _navigateTo(String route) {
    if (_navigateHandler != null) {
      _navigateHandler!(route);
    } else {
      // Simpan rute jika router belum siap saat inisialisasi awal
      _pendingInitialRoute = route;
    }
  }

  /// Utility untuk menyembunyikan sebagian token demi keamanan log/tampilan.
  static String _maskToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 12)}...';
  }

  /// Getter publik token yang sudah dimasking untuk ditampilkan di halaman Debug UI
  static String maskToken(String token) => _maskToken(token);
}
