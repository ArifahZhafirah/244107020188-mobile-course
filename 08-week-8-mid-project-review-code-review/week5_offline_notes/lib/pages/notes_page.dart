import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';

import 'package:go_router/go_router.dart';

import '../widgets/note_tile.dart';
import '../features/notes/domain/usecases/validate_note.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) async {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _showAddNoteDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddNoteDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final isOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_queue),
            tooltip: 'Catatan Tersinkronkan',
            onPressed: () {
              context.push('/posts');
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              color: Colors.deepOrange.shade50,
              child: Row(
                children: [
                  const Icon(
                    Icons.airplanemode_active,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Mode offline aktif - catatan tetap bisa dibaca & ditulis.',
                      style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Sync Status Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                dirtyCountAsync.when(
                  data: (count) {
                    final isAllSynced = count == 0;
                    return Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isAllSynced
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_queue,
                            color: isAllSynced ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isAllSynced
                                  ? 'Semua catatan sudah tersinkron'
                                  : '$count catatan belum tersinkron',
                              style: TextStyle(
                                color: isAllSynced
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Expanded(child: Text('Menghitung...')),
                  error: (_, _) => const Expanded(child: Text('Error')),
                ),
                TextButton.icon(
                  onPressed: () async {
                    try {
                      final syncRepo = ref.read(syncRepositoryProvider);
                      final noteRepo = ref.read(noteRepositoryProvider);

                      // Set loading state maybe, but codelab uses simple await
                      final synced = await syncRepo.syncNotes(noteRepo);
                      if (context.mounted && synced > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$synced catatan berhasil disinkronkan.',
                            ),
                          ),
                        );
                      }
                      ref.invalidate(dirtyCountProvider);
                      ref.invalidate(notesProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sinkronisasi gagal: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sync'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Notes List
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(child: Text('Belum ada catatan.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteTile(
                      note: note,
                      onTap: () {
                        context.push('/note/${note.id}');
                      },
                      onDelete: () async {
                        await ref
                            .read(noteRepositoryProvider)
                            .deleteNote(note.id!);
                        ref.invalidate(notesProvider);
                        ref.invalidate(dirtyCountProvider);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }
}

class AddNoteDialog extends ConsumerStatefulWidget {
  const AddNoteDialog({super.key});

  @override
  ConsumerState<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<AddNoteDialog> {
  static const _validateNote = ValidateNote();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(noteRepositoryProvider)
          .addNote(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
          );
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyCountProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan catatan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan baru'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateNote(value ?? ''),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
