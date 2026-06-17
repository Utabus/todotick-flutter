import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';
import 'package:flutter_application_ai/domain/enums/priority_level.dart';
import 'package:flutter_application_ai/domain/enums/task_status.dart';
import 'package:flutter_application_ai/domain/enums/repeat_type.dart';

/// Abstract interface — swap local ↔ Firebase dễ dàng
abstract class ITaskRepository {
  Future<List<Task>> getTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Stream<List<Task>> watchTasks();
}

/// Firestore implementation
class FirebaseTaskRepository implements ITaskRepository {
  final _col = FirebaseFirestore.instance.collection('tasks');

  // ── Convert Firestore doc → Task ──────────────────────────────────────────
  Task _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: d['title'] as String,
      description: d['description'] as String?,
      categoryId: d['categoryId'] as String? ?? 'all',
      priority: PriorityLevel.values.firstWhere(
        (e) => e.name == (d['priority'] as String? ?? 'level4'),
        orElse: () => PriorityLevel.level4,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (d['status'] as String? ?? 'todo'),
        orElse: () => TaskStatus.todo,
      ),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      dueTimeStr: d['dueTimeStr'] as String?,
      location: d['location'] as String?,
      emoji: d['emoji'] as String?,
      repeat: RepeatType.values.firstWhere(
        (e) => e.name == (d['repeat'] as String? ?? 'none'),
        orElse: () => RepeatType.none,
      ),
      reminderIds: List<String>.from(d['reminderIds'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Convert Task → Firestore map ──────────────────────────────────────────
  Map<String, dynamic> _toMap(Task t) => {
        'title': t.title,
        'description': t.description,
        'categoryId': t.categoryId,
        'priority': t.priority.name,
        'status': t.status.name,
        'dueDate': t.dueDate != null ? Timestamp.fromDate(t.dueDate!) : null,
        'dueTimeStr': t.dueTimeStr,
        'location': t.location,
        'emoji': t.emoji,
        'repeat': t.repeat.name,
        'reminderIds': t.reminderIds,
        'createdAt': Timestamp.fromDate(t.createdAt),
        'updatedAt': Timestamp.fromDate(t.updatedAt),
      };

  @override
  Future<List<Task>> getTasks() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    await _col.doc(task.id).set(_toMap(task));
  }

  @override
  Future<void> updateTask(Task task) async {
    await _col.doc(task.id).update(_toMap(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Stream<List<Task>> watchTasks() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(_fromDoc).toList(),
        );
  }
}
