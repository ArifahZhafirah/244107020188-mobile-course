class Announcement {
  final String id;
  final String category;
  final String date;
  final String title;
  final String preview;
  final String content;

  const Announcement({
    required this.id,
    required this.category,
    required this.date,
    required this.title,
    required this.preview,
    required this.content,
  });
}

const List<Announcement> sampleAnnouncements = [
  Announcement(
    id: '3',
    category: 'Akademik',
    date: '28 Sep 2026',
    title: 'Perubahan Ruang Kuliah Pemrograman Mobile',
    preview:
        'Perkuliahan tatap muka dialihkan sementara ke Lab Komputer 3 Lt. 7 Gedung Sipil.',
    content:
        'Diberitahukan kepada seluruh mahasiswa mata kuliah Pemrograman Mobile, perkuliahan tatap muka hari ini dialihkan sementara ke Laboratorium Komputer 3 Lantai 7 Gedung Sipil mulai pukul 13.00 WIB. Diharapkan hadir tepat waktu dengan membawa laptop serta progres repository proyek yang sedang berjalan.',
  ),
  Announcement(
    id: '2',
    category: 'Praktikum',
    date: '26 Sep 2026',
    title: 'Tenggat Submit Laporan Praktikum Minggu 6',
    preview:
        'Batas akhir pengumpulan laporan autentikasi dan FCM adalah hari Minggu pukul 23.59 WIB.',
    content:
        'Seluruh mahasiswa diwajibkan mengunggah tautan commit laporan praktikum Minggu 6 (Authentication, Security & FCM) ke repositori portofolio GitHub masing-masing paling lambat hari Minggu pukul 23.59 WIB. Pastikan menyertakan tabel checklist dan screenshot pengujian 3 state notifikasi.',
  ),
  Announcement(
    id: '1',
    category: 'Kegiatan',
    date: '21 Sep 2026',
    title: 'Kuliah Tamu: Keamanan dan Autentikasi Mobile',
    preview:
        'Sesi workshop daring bersama praktisi industri mengenai FCM dan JWT security.',
    content:
        'Jurusan Teknologi Informasi mengundang mahasiswa untuk mengikuti Kuliah Tamu bertema "Securing Modern Mobile Applications with JWT & Cloud Messaging" yang akan diadakan pada hari Sabtu pukul 09.00 WIB via Zoom Meeting. E-sertifikat dan materi pembelajaran disediakan gratis.',
  ),
];
