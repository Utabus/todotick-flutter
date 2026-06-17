import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';
import 'package:flutter_application_ai/domain/enums/priority_level.dart';
import 'package:flutter_application_ai/domain/enums/task_status.dart';
import 'package:flutter_application_ai/data/datasources/local/firebase_task_repository.dart';

// ── Repository provider (swap local ↔ Firebase tại đây) ───────────────────
final taskRepositoryProvider = Provider<FirebaseTaskRepository>(
  (ref) => FirebaseTaskRepository(),
);

// ── Stream-based task list (real-time Firestore) ───────────────────────────
final taskStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

// ── AsyncNotifier (để addTask / toggleComplete mutate state) ───────────────
final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(() {
  return TaskListNotifier();
});

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // Listen to real-time stream, update state automatically
    ref.listen(taskStreamProvider, (_, next) {
      next.whenData((tasks) => state = AsyncData(tasks));
    });
    return ref.read(taskRepositoryProvider).getTasks();
  }

  Future<void> addTask(Task task) async {
    await ref.read(taskRepositoryProvider).addTask(task);
    // Stream sẽ tự update state thông qua watchTasks
  }

  Future<void> toggleComplete(String taskId) async {
    final current = state.value ?? [];
    final task = current.firstWhere((t) => t.id == taskId);
    final isDone = task.status == TaskStatus.done;
    final updated = task.copyWith(
      status: isDone ? TaskStatus.todo : TaskStatus.done,
      updatedAt: DateTime.now(),
    );
    await ref.read(taskRepositoryProvider).updateTask(updated);
  }

  Future<void> deleteTask(String taskId) async {
    await ref.read(taskRepositoryProvider).deleteTask(taskId);
  }
}

// ── Filter Enum ────────────────────────────────────────────────────────────
enum TaskFilter { today, week, all }

// ── Notifier providers (Riverpod 3) ───────────────────────────────────────
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
        SelectedCategoryNotifier.new);

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.today;
  void set(TaskFilter f) => state = f;
}

final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

// ── Filtered Tasks ─────────────────────────────────────────────────────────
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <Task>[],
  );
  final categoryId = ref.watch(selectedCategoryProvider);
  final filter = ref.watch(taskFilterProvider);
  final now = DateTime.now();

  return tasks.where((task) {
    if (categoryId != null && categoryId != 'all') {
      if (task.categoryId != categoryId) return false;
    }
    if (task.dueDate == null) return filter == TaskFilter.all;
    final d = task.dueDate!;
    return switch (filter) {
      TaskFilter.today => d.year == now.year &&
          d.month == now.month &&
          d.day == now.day,
      TaskFilter.week => d.isAfter(now.subtract(const Duration(days: 1))) &&
          d.isBefore(now.add(const Duration(days: 7))),
      TaskFilter.all => true,
    };
  }).toList();
});

// ── Today Tasks ────────────────────────────────────────────────────────────
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <Task>[],
  );
  final now = DateTime.now();
  return tasks.where((task) {
    if (task.dueDate == null) return false;
    return task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;
  }).toList();
});

// ── Matrix Tasks ───────────────────────────────────────────────────────────
final matrixTasksProvider = Provider<Map<PriorityLevel, List<Task>>>((ref) {
  final tasks = ref.watch(taskListProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <Task>[],
  );
  return {
    for (final level in PriorityLevel.values)
      level: tasks.where((t) => t.priority == level).toList(),
  };
});
