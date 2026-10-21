import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'pages/notes_page.dart';
import 'pages/settings_page.dart';
import 'pages/posts_page.dart';
import 'pages/note_detail_page.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite biasa hanya jalan di Android/iOS.
  // Di desktop (Windows/Linux/macOS) harus memakai FFI.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prefsRepositoryProvider).markOpenedNow();
      ref.invalidate(lastOpenedProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkModeAsync = ref.watch(darkModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Offline Notes',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkModeAsync.maybeWhen(
        data: (isDark) => isDark ? ThemeMode.dark : ThemeMode.light,
        orElse: () => ThemeMode.light,
      ),
      routerConfig: router,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NotesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/posts',
        builder: (context, state) => const PostsPage(),
      ),
      GoRoute(
        path: '/note/:id',
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return NoteDetailPage(noteId: id);
        },
      ),
    ],
  );
});