import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/validate_note.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';

void main() {
  const validateNote = ValidateNote();

  test('menolak judul kosong', () {
    expect(validateNote(''), 'Judul catatan tidak boleh kosong.');
  });

  test('menolak judul yang hanya berisi spasi', () {
    expect(validateNote('   \t\n'), 'Judul catatan tidak boleh kosong.');
  });

  test('menerima judul valid', () {
    expect(validateNote('Catatan kuliah'), isNull);
  });

  test('menerima judul valid yang diapit spasi', () {
    expect(validateNote('  Catatan  '), isNull);
  });

  testWidgets('dialog menampilkan error saat judul kosong disimpan', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AddNoteDialog())),
      ),
    );

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);
  });
}
