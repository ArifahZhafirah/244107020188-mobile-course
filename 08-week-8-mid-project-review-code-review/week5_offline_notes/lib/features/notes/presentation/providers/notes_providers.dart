import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/local/db.dart';
import 'package:week5_offline_notes/features/notes/data/repositories/note_repository_impl.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';

// DI: satu-satunya tempat yang tahu implementasi konkret.
// Tipe provider adalah interface, bukan NoteRepositoryImpl.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// State daftar catatan untuk UI. Failure diubah jadi error yang ramah
// pengguna sehingga halaman cukup memakai .when(...).
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(noteRepositoryProvider).fetchNotes();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
});

final dirtyCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.count;
});

final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(noteRepositoryProvider).getNoteById(id);
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.note;
});

// Aksi dari UI. Halaman memanggil ini, bukan repository.
// Mengembalikan pesan error (null bila sukses) agar UI bisa menampilkan
// SnackBar tanpa perlu mengenal Failure.
class NotesActions {
  NotesActions(this._ref);
  final Ref _ref;

  Future<String?> add(String title, String body) async {
    final result = await _ref
        .read(noteRepositoryProvider)
        .addNote(title: title, body: body);
    _refresh();
    return result.failure?.message;
  }

  Future<String?> delete(int id) async {
    final failure = await _ref.read(noteRepositoryProvider).deleteNote(id);
    _refresh();
    return failure?.message;
  }

  void _refresh() {
    _ref.invalidate(notesProvider);
    _ref.invalidate(dirtyCountProvider);
  }
}

final notesActionsProvider = Provider<NotesActions>((ref) => NotesActions(ref));
