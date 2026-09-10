// Nama: Arifah Zhafirah Wikananda
// NIM: 244107020188
// Kelas: 2F
// Tugas: Academic Overview Dashboard
// Revisi: Refactoring Challenge

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Breakpoint untuk menentukan layout mobile dan desktop.
const double kWideBreakpoint = 600.0;

void main() {
  runApp(const DashboardApp());
}

/// Widget utama aplikasi.
class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Overview',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) {
          setState(() {
            isDark = value;
          });
        },
      ),
    );
  }
}

/// Halaman utama dashboard.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.isDark,
    required this.onDarkChanged,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              const SizedBox(width: 4),
              CupertinoSwitch(
                value: isDark,
                onChanged: onDarkChanged,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmall =
              constraints.maxWidth < kWideBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfile(context),
                const SizedBox(height: 20),

                _buildInfoCards(
                  context,
                  isSmall,
                ),

                const SizedBox(height: 20),

                _buildProgress(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WIDGET PROFIL
  // ============================================================

  Widget _buildProfile(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF6D28D9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Foto profil Arifah Zhafirah Wikananda',
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Text(
                'AZ',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arifah Zhafirah Wikananda',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  '244107020188 · Kelas 2F',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildChip(
                      context,
                      Icons.school,
                      'Semester 4',
                    ),
                    _buildChip(
                      context,
                      Icons.star,
                      'GPA 3.85',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET CHIP
  // ============================================================

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),

          const SizedBox(width: 4),

          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET KARTU INFORMASI
  // ============================================================

  Widget _buildInfoCards(
    BuildContext context,
    bool isSmall,
  ) {
    const List<InfoCard> cards = [
      InfoCard(
        icon: Icons.book,
        title: 'Mata Kuliah',
        value: '12',
        subtitle: 'Aktif',
        color: Colors.blue,
      ),

      InfoCard(
        icon: Icons.assignment,
        title: 'Tugas',
        value: '8',
        subtitle: 'Menunggu',
        color: Colors.orange,
      ),

      InfoCard(
        icon: Icons.grade,
        title: 'Nilai Rata-rata',
        value: 'A-',
        subtitle: '85.5%',
        color: Colors.green,
      ),

      InfoCard(
        icon: Icons.calendar_today,
        title: 'Kehadiran',
        value: '92%',
        subtitle: 'Bulan Ini',
        color: Colors.purple,
      ),
    ];

    // ==========================================================
    // MOBILE
    // ==========================================================

    if (isSmall) {
      return Column(
        children: [
          for (final card in cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            ),
        ],
      );
    }

    // ==========================================================
    // DESKTOP
    // ==========================================================

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[2],
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            children: [
              cards[1],
              const SizedBox(height: 12),
              cards[3],
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WIDGET PROGRESS AKADEMIK
  // ============================================================

  Widget _buildProgress(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Akademik',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  context,
                  'Selesai',
                  '68%',
                  Colors.green,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildProgressItem(
                  context,
                  'Berjalan',
                  '24%',
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildProgressItem(
                  context,
                  'Belum Mulai',
                  '8%',
                  Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ITEM PROGRESS
  // ============================================================

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget reusable untuk kartu informasi akademik.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),

                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),

                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}