import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/validate_note.dart';

import 'package:week5_offline_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week5_offline_notes/pages/note_detail_page.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';


class FakeNoteRepository implements NoteRepository {
  int addCalls = 0;
  bool failAdd = false;
  final List<Note> notes = [];

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: List<Note>.of(notes), failure: null);

  @override
  Future<({Note? note, Failure? failure})> getNoteById(int id) async {
    for (final note in notes) {
      if (note.id == id) return (note: note, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    if (failAdd) {
      return (
        note: null,
        failure: const LocalFailure('database detail should not reach UI'),
      );
    }
    final note = Note(
      id: addCalls,
      title: title,
      body: body,
      updatedAt: DateTime(2026),
    );
    notes.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    notes.removeWhere((note) => note.id == id);
    return null;
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async =>
      (count: 0, failure: null);

  @override
  Future<Failure?> markAllSynced() async => null;
}

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
<<<<<<< Updated upstream
=======

  test('menerima judul valid yang diapit spasi', () {
    expect(validateNote('  Catatan  '), isNull);
  });

  testWidgets('dialog menampilkan error saat judul kosong disimpan', (
    tester,
  ) async {
    final repository = FakeNoteRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: MaterialApp(home: Scaffold(body: AddNoteDialog())),
      ),
    );

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);
    expect(repository.addCalls, 0);
  });

  testWidgets('dialog menyimpan judul valid', (tester) async {
    final repository = FakeNoteRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: MaterialApp(home: Scaffold(body: AddNoteDialog())),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Catatan baru');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(repository.addCalls, 1);
  });

  testWidgets('dialog menampilkan pesan aman saat penyimpanan gagal', (
    tester,
  ) async {
    final repository = FakeNoteRepository()..failAdd = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: MaterialApp(home: Scaffold(body: AddNoteDialog())),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Catatan baru');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(repository.addCalls, 1);
    expect(find.text('Gagal menyimpan catatan. Coba lagi.'), findsOneWidget);
    expect(
      find.textContaining('database detail should not reach UI'),
      findsNothing,
    );
  });

  testWidgets('halaman daftar menampilkan catatan dari feature provider', (
    tester,
  ) async {
    final repository = FakeNoteRepository()
      ..notes.add(
        Note(id: 7, title: 'Catatan dari feature', updatedAt: DateTime(2026)),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catatan dari feature'), findsOneWidget);
  });

  testWidgets('halaman detail membaca catatan dari feature provider', (
    tester,
  ) async {
    final repository = FakeNoteRepository()
      ..notes.add(
        Note(
          id: 7,
          title: 'Judul detail',
          body: 'Isi detail',
          updatedAt: DateTime(2026),
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: const MaterialApp(home: NoteDetailPage(noteId: 7)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Judul detail'), findsOneWidget);
    expect(find.text('Isi detail'), findsOneWidget);
  });

  testWidgets('aksi hapus memperbarui daftar catatan', (tester) async {
    final repository = FakeNoteRepository()
      ..notes.add(
        Note(id: 7, title: 'Catatan untuk dihapus', updatedAt: DateTime(2026)),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWith((ref) => repository)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(repository.notes, isEmpty);
    expect(find.text('Catatan untuk dihapus'), findsNothing);
  });

}
