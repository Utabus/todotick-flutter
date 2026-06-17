import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';
import 'package:flutter_application_ai/data/repositories/task_repository.dart';
import 'package:flutter_application_ai/domain/enums/priority_level.dart';
import 'package:flutter_application_ai/domain/enums/task_status.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());

// ── Main Task List ─────────────────────────────────────────────────────────
final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(() {
  return TaskListNotifier();
});

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return ref.read(taskRepositoryProvider).getTasks();
  }

  Future<void> addTask(Task task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).addTask(task);
      return ref.read(taskRepositoryProvider).getTasks();
    });
  }

  Future<void> toggleComplete(String taskId) async {
    final current = state.value ?? [];
    final updated = current.map((t) {
      if (t.id != taskId) return t;
      final isDone = t.status == TaskStatus.done;
      return t.copyWith(
        status: isDone ? TaskStatus.todo : TaskStatus.done,
        updatedAt: DateTime.now(),
      );
    }).toList();
    state = AsyncData(updated);
  }
}

// ── Filter Enum ────────────────────────────────────────────────────────────
enum TaskFilter { today, week, all }

// ── Selected Category (Notifier instead of StateProvider) ─────────────────
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
        SelectedCategoryNotifier.new);

// ── Task Filter Notifier ────────────────────────────────────────────────────
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
    if (task.dueDate == null) {
      return filter == TaskFilter.all;
    }
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
    PriorityLevel.level1:
        tasks.where((t) => t.priority == PriorityLevel.level1).toList(),
    PriorityLevel.level2:
        tasks.where((t) => t.priority == PriorityLevel.level2).toList(),
    PriorityLevel.level3:
        tasks.where((t) => t.priority == PriorityLevel.level3).toList(),
    PriorityLevel.level4:
        tasks.where((t) => t.priority == PriorityLevel.level4).toList(),
  };
});
