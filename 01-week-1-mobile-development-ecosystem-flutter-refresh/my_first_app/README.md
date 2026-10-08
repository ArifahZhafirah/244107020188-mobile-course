# Week 1 — Mobile Development Ecosystem & Flutter Refresh (my_first_app)

Aplikasi Flutter pertama berupa **Profil Mahasiswa** yang dibuat untuk mengulang dasar ekosistem pengembangan mobile, Dart, dan Flutter. Proyek ini mencakup setup lingkungan (Flutter SDK, Android SDK, emulator/perangkat fisik), praktikum mengubah UI default, latihan mandiri Dart, serta mini assignment.

| Item | Keterangan |
|---|---|
| Nama / NIM | Arifah Zhafirah / 244107020188 |
| Bahasa & framework | Dart, Flutter (Material) |
| Target perangkat | Android (emulator / perangkat fisik) |
| Widget utama | `MaterialApp`, `Scaffold`, `AppBar`, `Center`, `Column`, `Icon`, `Text`, `SizedBox` |
| Version control | Git + GitHub ([repository portfolio](https://github.com/ArifahZhafirah/244107020188-mobile-course/tree/main/01-week-1-mobile-development-ecosystem-flutter-refresh)) |

## 1. Setup dan struktur proyek

Langkah instalasi yang dilakukan:

1. Instal Git, lalu verifikasi dengan `git --version`.
2. Instal VS Code beserta ekstensi **Flutter** (Dart ikut terpasang).
3. Instal Flutter SDK dan tambahkan `flutter/bin` ke `PATH`.
4. Instal Android Studio, Android SDK, Command-line Tools, dan emulator melalui SDK Manager serta Device Manager.
5. Verifikasi seluruh lingkungan:

```bash
flutter --version
flutter doctor
flutter doctor --android-licenses
flutter devices
```

Proyek dibuat dengan:

```bash
flutter create my_first_app
cd my_first_app
flutter run
```

Struktur folder pada repository:

```
01-week-1-mobile-development-ecosystem-flutter-refresh/
├── README.md
├── lib/
│   └── main.dart            # UI Profil Mahasiswa
├── test/
└── Screenshot/
    ├── Praktikum.jpeg
    ├── LatihanMandiri.png
    └── Assignment.jpeg
```

Peran folder utama: `lib/` berisi kode aplikasi (titik awal `lib/main.dart`), `test/` untuk unit dan widget test, `android/`, `ios/`, `web/` untuk konfigurasi platform, dan `pubspec.yaml` untuk metadata, dependency, aset, serta versi SDK.

## 2. Konsep dasar

### Evolusi pengembangan mobile

| Pendekatan | Ciri utama | Contoh |
|---|---|---|
| Native | Kode dan UI khusus tiap platform; akses API perangkat paling langsung | Kotlin, Swift |
| Hybrid | Aplikasi web dalam pembungkus native | Ionic, Cordova |
| Cross-platform | Satu basis kode untuk beberapa platform | Flutter, React Native |

Pemilihan teknologi bergantung pada performa, akses fitur perangkat, keahlian tim, biaya, dan target platform. Cross-platform tidak selalu menggantikan native karena keduanya memiliki trade-off.

### Arsitektur Flutter dan peran Dart

Flutter terdiri dari **framework** (widget dan API), **engine** (rendering, teks, grafis), dan **embedder** yang menghubungkan aplikasi ke Android, iOS, web, atau desktop. Dart mendukung *just-in-time* (JIT) saat pengembangan, sehingga hot reload memungkinkan, dan *ahead-of-time* (AOT) saat build rilis untuk performa optimal.

### Widget tree

UI Flutter bersifat deklaratif: UI menggambarkan state saat ini, dan semua bagiannya adalah widget yang disusun sebagai pohon.

```
MaterialApp
└── Scaffold
    ├── AppBar → Text
    └── Center
        └── Column
            ├── Icon
            ├── SizedBox
            ├── Text (nama)
            └── Text (keterangan)
```

### Hot reload vs hot restart

| | Hot reload | Hot restart |
|---|---|---|
| Efek pada state | Umumnya dipertahankan | Hilang, aplikasi dijalankan ulang dari awal |
| Shortcut terminal | `r` | `R` |
| Dipakai untuk | Iterasi UI cepat | Perubahan yang tidak bisa diterapkan lewat hot reload, misalnya inisialisasi aplikasi |

## 3. Praktikum — Mengubah UI default

Isi `lib/main.dart` diganti menjadi tampilan profil sederhana. Kode dasar dari praktikum:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.school, size: 72),
            SizedBox(height: 16),
            Text('Arifah Zhafirah', style: TextStyle(fontSize: 24)),
            Text('Pemrograman Mobile — Minggu 1'),
          ]),
        ),
      ),
    );
  }
}
```

Setelah menyimpan file, perubahan teks dan ikon diamati melalui hot reload, lalu dibandingkan dengan hot restart.

| Hasil praktikum |
|---|
| ![mini](/01-week-1-mobile-development-ecosystem-flutter-refresh/Screenshot/Praktikum.jpeg) |

## 4. Latihan mandiri (Dart)

Tiga tugas latihan:

1. Fungsi `hitungLuasPersegiPanjang` yang menerima panjang dan lebar bertipe `double`.
2. Class `Profil` dengan properti `nama`, `nim`, dan `email` (email boleh kosong / nullable).
3. Pemanggilan keduanya dari `main()` dengan penanganan email kosong secara aman.

Konsep null safety yang dipakai: tipe nullable ditandai `?`, nilai dicek dengan operator `?.` dan `??` alih-alih memakai `!` secara sembarangan.

```dart
// TODO: tempel kode latihan mandiri milikmu di sini
```

| Hasil latihan mandiri |
|---|
| ![mini](/01-week-1-mobile-development-ecosystem-flutter-refresh/Screenshot/LatihanMandiri.png) |

## 5. Mini assignment — Aplikasi Profil Mahasiswa

Aplikasi pada praktikum dikembangkan dengan menambahkan **NIM** dan **satu informasi tambahan** menggunakan widget dasar.

| Informasi | Isi |
|---|---|
| Nama | Arifah Zhafirah |
| NIM | 244107020188 |
| Informasi tambahan | *(isi, misalnya program studi / kampus / hobi)* |

| Hasil assignment |
|---|
| ![mini](/01-week-1-mobile-development-ecosystem-flutter-refresh/Screenshot/Assignment.jpeg) |

### Kendala setup yang ditemui

*(Isi satu kendala nyata yang kamu alami, misalnya `flutter doctor` menampilkan lisensi Android belum diterima, perangkat tidak terdeteksi di `flutter devices`, atau emulator lambat. Tulis penyebab dan cara kamu menyelesaikannya.)*

## 6. Version control

Repository diinisialisasi dan diunggah ke GitHub:

```bash
git init
git add .
git commit -m "feat: create week 1 Flutter profile app"
git branch -M main
git remote add origin https://github.com/ArifahZhafirah/244107020188-mobile-course.git
git push -u origin main
```

Folder ini adalah bagian dari repository portfolio 16 minggu `244107020188-mobile-course`. Token dan kredensial tidak diunggah, dan `git status` diperiksa sebelum setiap commit.

## 7. Checklist verifikasi mandiri

| No | Kriteria | Status |
|---|---|---|
| 1 | `flutter doctor` tanpa masalah yang menghambat target Android | ✅ |
| 2 | `flutter devices` mendeteksi emulator / perangkat fisik | ✅ |
| 3 | Aplikasi berjalan dan UI default sudah diganti menjadi profil sederhana | ✅ |
| 4 | Dapat menjelaskan perbedaan hot reload dan hot restart | ✅ |
| 5 | Repository remote berisi source code, README, screenshot, dan riwayat commit | ✅ |

## 8. Refleksi

**1. Kapan native lebih tepat dipilih daripada cross-platform?**
Native lebih tepat ketika aplikasi membutuhkan performa maksimal atau akses mendalam ke API perangkat (misalnya pemrosesan grafis berat, sensor khusus, atau fitur platform terbaru yang belum didukung plugin), serta ketika tim memang sudah punya keahlian Kotlin/Swift. Untuk aplikasi umum dengan target banyak platform dan sumber daya terbatas, cross-platform seperti Flutter lebih efisien.

**2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**
Pada UI deklaratif, tampilan adalah fungsi dari state: UI = f(state). Ketika state berubah, Flutter membangun ulang bagian widget tree yang terdampak sehingga tampilan selalu sesuai dengan state terbaru, tanpa perlu mengubah elemen UI secara manual.

**3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?**
Commit kecil membuat perubahan mudah ditinjau, dilacak, dan dibatalkan bila ada masalah. Pesan yang jelas (misalnya `feat: ...`, `fix: ...`) menjadi dokumentasi riwayat pengerjaan, memudahkan rekan tim memahami konteks, dan menunjukkan progres belajar secara rapi pada portfolio.

## 9. Cara menjalankan

```bash
cd 01-week-1-mobile-development-ecosystem-flutter-refresh/my_first_app
flutter pub get
flutter run
```
