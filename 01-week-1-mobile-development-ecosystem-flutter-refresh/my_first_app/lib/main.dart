import 'package:flutter/material.dart';

// 2. Class Profil dengan properti nama, nim, dan email
class Profil {
  String nama;
  String nim;
  String? email; // Email boleh kosong (nullable)
  
  Profil({
    required this.nama,
    required this.nim,
    this.email,
  });
  
  // Method untuk menampilkan informasi profil
  void tampilkanProfil() {
    print('=== Profil Mahasiswa ===');
    print('Nama: $nama');
    print('NIM: $nim');
    // 3. Tangani email kosong dengan aman
    if (email != null && email!.isNotEmpty) {
      print('Email: $email');
    } else {
      print('Email: (tidak tersedia)');
    }
    print('========================');
  }
}

// 1. Fungsi hitungLuasPersegiPanjang
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

void main() {
  // 3. Panggil fungsi hitungLuasPersegiPanjang
  double panjang = 5.0;
  double lebar = 3.0;
  double luas = hitungLuasPersegiPanjang(panjang, lebar);
  print('Luas persegi panjang (p=$panjang, l=$lebar) = $luas');
  print(''); // Spasi kosong
  
  // 3. Buat dan panggil class Profil dengan email yang terisi
  Profil profil1 = Profil(
    nama: 'Arifah Zhafirah Wikananda',
    nim: '244107020188',
    email: 'arifahzhafirah206@gmail.com',
  );
  profil1.tampilkanProfil();
  print(''); // Spasi kosong
  
  // 3. Buat dan panggil class Profil dengan email kosong
  Profil profil2 = Profil(
    nama: 'Budi Santoso',
    nim: '244107020189',
    // email tidak diisi (null)
  );
  profil2.tampilkanProfil();
  print(''); // Spasi kosong
  
  // Menjalankan aplikasi Flutter
  runApp(const MyApp());
}

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
            Text('Arifah Zhafirah Wikananda', style: TextStyle(fontSize: 24)),
            Text('244107020188', style: TextStyle(fontSize: 24)),
            Text('arifahzhafirah206@gmail.com', style: TextStyle(fontSize: 24)),
            Text('Pemrograman Mobile — Minggu 1'),
          ]),
        ),
      ),
    );
  }
}