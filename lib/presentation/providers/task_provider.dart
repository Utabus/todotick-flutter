import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';
import 'package:flutter_application_ai/domain/enums/priority_level.dart';
import 'package:flutter_application_ai/domain/enums/task_status.dart';
import 'package:flutter_application_ai/data/datasources/local/firebase_task_repository.dart';
import 'package:uuid/uuid.dart';

// ── Repository provider ────────────────────────────────────────────────────
final taskRepositoryProvider = Provider<FirebaseTaskRepository>(
  (ref) => FirebaseTaskRepository(),
);

// ── Real-time stream từ Firestore ──────────────────────────────────────────
final taskStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

// ── Main AsyncNotifier ─────────────────────────────────────────────────────
final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(() {
  return TaskListNotifier();
});

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // Khi stream cập nhật → tự update state
    ref.listen(taskStreamProvider, (_, next) {
      next.whenData((tasks) => state = AsyncData(tasks));
    });

    final repo = ref.read(taskRepositoryProvider);
    final existing = await repo.getTasks();

    // Nếu Firestore trống → seed mock data
    if (existing.isEmpty) {
      await _seedMockData(repo);
      return repo.getTasks();
    }

    return existing;
  }

  Future<void> _seedMockData(FirebaseTaskRepository repo) async {
    final now = DateTime.now();
    final mockTasks = [
      Task(
        id: const Uuid().v4(),
        title: 'Ăn trưa với khách hàng',
        categoryId: '1',
        priority: PriorityLevel.level1,
        status: TaskStatus.todo,
        dueDate: now,
        dueTimeStr: '12:00',
        location: 'Nhà hàng ngon',
        emoji: '🍽️',
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Trả lời email của khách hàng',
        categoryId: '1',
        priority: PriorityLevel.level1,
        status: TaskStatus.todo,
        dueDate: now,
        dueTimeStr: '09:00',
        emoji: '📧',
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Trò chơi bóng rổ',
        categoryId: '2',
        priority: PriorityLevel.level3,
        status: TaskStatus.todo,
        dueDate: now,
        dueTimeStr: '19:00',
        emoji: '🏀',
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Gặp gỡ bạn bè',
        categoryId: '2',
        priority: PriorityLevel.level2,
        status: TaskStatus.todo,
        dueDate: now.add(const Duration(days: 1)),
        emoji: '🍻',
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Đọc sách',
        categoryId: '2',
        priority: PriorityLevel.level4,
        status: TaskStatus.todo,
        dueDate: now.add(const Duration(days: 2)),
        emoji: '📚',
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Lên kế hoạch cho lịch trình ngày mai',
        categoryId: '1',
        priority: PriorityLevel.level2,
        status: TaskStatus.todo,
        dueDate: now.add(const Duration(days: 1)),
        emoji: '📋',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final task in mockTasks) {
      await repo.addTask(task);
    }
  }

  Future<void> addTask(Task task) async {
    await ref.read(taskRepositoryProvider).addTask(task);
  }

  Future<void> toggleComplete(String taskId) async {
    final current = state.value ?? [];
    final task = current.firstWhere((t) => t.id == taskId,
        orElse: () => throw Exception('Task not found'));
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

// ── Notifier providers ─────────────────────────────────────────────────────
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
