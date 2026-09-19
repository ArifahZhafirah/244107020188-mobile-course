import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/main.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // Tap tombol + untuk buka dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Isi TextField dan tap "Tambah"
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();   // ← INI KUNCI PERBAIKANNYA

    // Verifikasi tugas muncul (cuma di list, bukan di TextField)
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}