import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> getNoteById(int id);
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });
  Future<Failure?> deleteNote(int id);
  Future<({int count, Failure? failure})> countDirty();
  Future<Failure?> markAllSynced();
}