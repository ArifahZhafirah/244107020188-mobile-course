/// Definisi konstan seluruh rute pada aplikasi Campus Notify.
/// Memastikan deep link dari FCM, GoRouter, dan navigasi UI memakai nilai yang konsisten.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String announcement = '/pengumuman/:id';

  /// Helper untuk membangun path pengumuman dengan parameter ID
  /// Contoh: AppRoutes.announcementPath('3') -> '/pengumuman/3'
  static String announcementPath(String id) => '/pengumuman/$id';
}

/// Fungsi murni (pure function) untuk mengekstrak dan menormalkan path rute
/// dari data payload FCM (`RemoteMessage.data`).
///
/// Fungsi ini independen dan dapat diuji secara unit test tanpa memerlukan SDK Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final rawRoute = data['route']?.toString().trim();
  if (rawRoute == null || rawRoute.isEmpty) {
    return AppRoutes.home;
  }
  return rawRoute.startsWith('/') ? rawRoute : '/$rawRoute';
}
