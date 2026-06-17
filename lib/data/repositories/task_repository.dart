import '../../domain/entities/task.dart';
import '../../domain/enums/priority_level.dart';
import '../../domain/enums/task_status.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  final List<Task> _tasks = [
    Task(
      id: const Uuid().v4(),
      title: 'Ăn trưa với khách hàng',
      categoryId: '1',
      priority: PriorityLevel.level1,
      status: TaskStatus.todo,
      dueDate: DateTime.now(),
      location: 'Nhà hàng ngon',
      emoji: '🍽️',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Gặp gỡ bạn bè',
      categoryId: '2',
      priority: PriorityLevel.level2,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      emoji: '🍻',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: const Uuid().v4(),
      title: 'Đọc sách',
      categoryId: '2',
      priority: PriorityLevel.level3,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      emoji: '📚',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _tasks;
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }
}
