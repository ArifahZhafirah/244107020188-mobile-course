import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import 'package:go_router/go_router.dart';
import '../widgets/note_tile.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) async {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Catatan baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Isi (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                
                await ref.read(noteRepositoryProvider).addNote(
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                    );
                ref.invalidate(notesProvider);
                ref.invalidate(dirtyCountProvider);
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: Colors.deepOrange.shade50,
              child: Row(
                children: [
                  const Icon(Icons.airplanemode_active, color: Colors.deepOrange, size: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                dirtyCountAsync.when(
                  data: (count) {
                    final isAllSynced = count == 0;
                    return Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isAllSynced ? Icons.cloud_done_outlined : Icons.cloud_queue,
                            color: isAllSynced ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isAllSynced ? 'Semua catatan sudah tersinkron' : '$count catatan belum tersinkron',
                              style: TextStyle(
                                color: isAllSynced ? Colors.green : Colors.orange,
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
                          SnackBar(content: Text('$synced catatan berhasil disinkronkan.')),
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
                        await ref.read(noteRepositoryProvider).deleteNote(note.id!);
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
        onPressed: () => _showAddNoteDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }
}