import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
import 'product_page.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: filter == TodoFilter.all,
                  onSelected: (_) =>
                      ref.read(todoFilterProvider.notifier).set(TodoFilter.all),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Belum selesai'),
                  selected: filter == TodoFilter.active,
                  onSelected: (_) => ref
                      .read(todoFilterProvider.notifier)
                      .set(TodoFilter.active),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Selesai'),
                  selected: filter == TodoFilter.completed,
                  onSelected: (_) => ref
                      .read(todoFilterProvider.notifier)
                      .set(TodoFilter.completed),
                ),
              ],
            ),
          ),

          // Daftar tugas
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('Belum ada tugas'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoTile(
                        todo: todo,
                        onToggle: () =>
                            ref.read(todoListProvider.notifier).toggle(todo),
                        onRemove: () =>
                            ref.read(todoListProvider.notifier).remove(todo),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}