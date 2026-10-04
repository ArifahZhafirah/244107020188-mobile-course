import 'package:go_router/go_router.dart';
import 'pages/stats_page.dart';
import 'pages/todo_page.dart';
import 'widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute: NavigationBar tetap tampil di semua halaman di dalamnya.
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
  ],
);