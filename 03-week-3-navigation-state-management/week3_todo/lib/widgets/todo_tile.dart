import 'package:flutter/material.dart';

/// Satu baris tugas. Dipisah supaya TodoPage lebih pendek
/// dan widget ini bisa diuji sendiri.
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.title,
    required this.done,
    required this.onToggle,
    required this.onDelete,
  });

  final String title;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: done,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        title,
        style: TextStyle(
          decoration: done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}