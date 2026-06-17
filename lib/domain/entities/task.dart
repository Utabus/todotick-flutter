import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/priority_level.dart';
import '../enums/task_status.dart';
import '../enums/repeat_type.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    required String categoryId,
    @Default(PriorityLevel.level4) PriorityLevel priority,
    @Default(TaskStatus.todo) TaskStatus status,
    DateTime? dueDate,
    String? dueTimeStr,
    String? location,
    String? emoji,
    @Default(RepeatType.none) RepeatType repeat,
    @Default([]) List<String> reminderIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
