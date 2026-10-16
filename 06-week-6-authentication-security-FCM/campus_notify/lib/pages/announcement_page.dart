import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/announcement_data.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    // Cari pengumuman berdasarkan ID, atau gunakan fallback pengumuman #3
    final announcement = sampleAnnouncements.firstWhere(
      (item) => item.id == id,
      orElse: () => Announcement(
        id: id,
        category: 'Akademik',
        date: '28 Sep 2026',
        title: 'Pengumuman #$id',
        preview: 'Detail pengumuman kampus',
        content:
            'Perkuliahan tatap muka dialihkan sementara ke Laboratorium Komputer 3 Lantai 7 Gedung Sipil mulai pukul 13.00 WIB. Diharapkan hadir tepat waktu dengan membawa laptop serta progres repository proyek yang sedang berjalan.',
      ),
    );

    debugPrint('[UI] Menampilkan detail pengumuman #$id: ${announcement.title}');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          'Pengumuman',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Chip + Date
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    announcement.category,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  announcement.date,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              announcement.title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Full Content Paragraph
            Text(
              announcement.content,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const Spacer(),

            // Box Deep Link di bagian bawah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dibuka dari deep link: ${AppRoutes.announcementPath(id)}',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
