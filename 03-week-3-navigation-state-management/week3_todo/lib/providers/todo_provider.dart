import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(title)];

  // Pakai object Todo, bukan index
  void toggle(Todo todo) {
    state = [
      for (final t in state)
        if (identical(t, todo) || t == todo)
          t.copyWith(done: !t.done)
        else
          t,
    ];
  }

  void remove(Todo todo) {
    state = state.where((t) => !identical(t, todo) && t != todo).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

enum TodoFilter { all, active, completed }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return switch (filter) {
    TodoFilter.all => todos,
    TodoFilter.active => todos.where((t) => !t.done).toList(),
    TodoFilter.completed => todos.where((t) => t.done).toList(),
  };
});