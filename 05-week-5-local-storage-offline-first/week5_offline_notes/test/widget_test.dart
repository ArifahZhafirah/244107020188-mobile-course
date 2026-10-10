import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:week5_offline_notes/main.dart';

void main() {
  setUpAll(() {
    // flutter test jalan di desktop, jadi sqflite harus pakai FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    // SharedPreferences palsu supaya tidak butuh plugin platform
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App menampilkan halaman catatan', (WidgetTester tester) async {
    // MyApp memakai Riverpod, jadi wajib dibungkus ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Beri waktu operasi database/prefs yang asli (async I/O)
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();

    expect(find.text('Catatan Offline'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget); // label tombol FAB
  });
}