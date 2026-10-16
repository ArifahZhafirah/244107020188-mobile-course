import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Praktikum 2 ① — inisialisasi Firebase (wajib sebelum pakai FCM / Auth).
  await Firebase.initializeApp();

  // Praktikum 2 ② — runApp lebih dulu agar UI langsung tampil,
  // lalu FCM init berjalan di background (tidak di-await agar tidak black screen).
  runApp(const ProviderScope(child: CampusNotifyApp()));

  // Init FCM setelah widget tree siap — minta izin, ambil token, pasang handler, dan router.
  PushService.instance.init(
    onNavigate: (route) => _router.go(route),
  );
}

// ─── Router ───────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (_, _) => const _AuthGate(),
    ),
    GoRoute(
      path: AppRoutes.announcement,
      builder: (_, state) =>
          AnnouncementPage(id: state.pathParameters['id'] ?? ''),
    ),
  ],
);

// ─── Root widget ──────────────────────────────────────────────────────────────

class CampusNotifyApp extends StatelessWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// ─── Auth gate: cek token dari secure storage, arahkan ke Login / Home ────────

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const LoginPage(),
      data: (isLoggedIn) => isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}