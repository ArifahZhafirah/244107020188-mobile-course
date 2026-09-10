// Nama: Arifah Zhafirah Wikananda
// NIM: 244107020188
// Kelas: 2F
// Tugas: Academic Overview Dashboard

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          bool isSmall = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfile(context),
                const SizedBox(height: 20),
                _buildInfoCards(context, isSmall),
                const SizedBox(height: 20),
                _buildProgress(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // WIDGET PROFIL - DIPERBAIKI
  // ============================================
  Widget _buildProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
              'https://ui-avatars.com/api/?name=Arifah+Zhafirah&background=7C3AED&color=fff&size=128',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arifah Zhafirah Wikananda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '244107020188 · Kelas 2F',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // CHIP dengan Wrap - SEKARANG TERLIHAT!
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildChip(Icons.school, 'Semester 4'),
                    _buildChip(Icons.star, 'GPA 3.85'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGET CHIP (dipisah biar rapi)
  // ============================================
  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGET KARTU INFORMASI
  // ============================================
  Widget _buildInfoCards(BuildContext context, bool isSmall) {
    final List<Map<String, dynamic>> cardData = [
      {
        'icon': Icons.book,
        'title': 'Mata Kuliah',
        'value': '12',
        'subtitle': 'Aktif',
        'color': Colors.blue,
      },
      {
        'icon': Icons.assignment,
        'title': 'Tugas',
        'value': '8',
        'subtitle': 'Menunggu',
        'color': Colors.orange,
      },
      {
        'icon': Icons.grade,
        'title': 'Nilai Rata-rata',
        'value': 'A-',
        'subtitle': '85.5%',
        'color': Colors.green,
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Kehadiran',
        'value': '92%',
        'subtitle': 'Bulan Ini',
        'color': Colors.purple,
      },
    ];

    if (isSmall) {
      return Column(
        children: cardData.map((data) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSingleCard(
              context,
              data['icon'],
              data['title'],
              data['value'],
              data['subtitle'],
              data['color'],
            ),
          );
        }).toList(),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildSingleCard(
                  context,
                  cardData[0]['icon'],
                  cardData[0]['title'],
                  cardData[0]['value'],
                  cardData[0]['subtitle'],
                  cardData[0]['color'],
                ),
                const SizedBox(height: 12),
                _buildSingleCard(
                  context,
                  cardData[2]['icon'],
                  cardData[2]['title'],
                  cardData[2]['value'],
                  cardData[2]['subtitle'],
                  cardData[2]['color'],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildSingleCard(
                  context,
                  cardData[1]['icon'],
                  cardData[1]['title'],
                  cardData[1]['value'],
                  cardData[1]['subtitle'],
                  cardData[1]['color'],
                ),
                const SizedBox(height: 12),
                _buildSingleCard(
                  context,
                  cardData[3]['icon'],
                  cardData[3]['title'],
                  cardData[3]['value'],
                  cardData[3]['subtitle'],
                  cardData[3]['color'],
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSingleCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: color.withOpacity(0.1),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGET PROGRESS
  // ============================================
  Widget _buildProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Akademik',
            style: TextStyle(
              fontSize: 18,
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

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}