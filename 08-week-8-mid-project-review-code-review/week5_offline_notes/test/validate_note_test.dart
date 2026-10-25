import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/validate_note.dart';

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
}
