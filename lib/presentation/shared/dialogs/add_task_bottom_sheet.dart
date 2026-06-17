import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/enums/priority_level.dart';
import '../../../domain/enums/repeat_type.dart';
import '../../providers/task_provider.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _location;
  String _emoji = '📝';
  PriorityLevel _priority = PriorityLevel.level4;
  RepeatType _repeat = RepeatType.none;

  final _emojis = ['📝', '🍽️', '💼', '🏀', '🎮', '📚', '🏠', '🚗', '🏃', '🎵'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      categoryId: '1',
      priority: _priority,
      dueDate: _selectedDate,
      dueTimeStr: _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : null,
      location: _location,
      emoji: _emoji,
      repeat: _repeat,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(taskListProvider.notifier).addTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Thêm công việc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Task title input
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tên công việc...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixText: '$_emoji  ',
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // Emoji picker
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => _emoji = _emojis[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _emoji == _emojis[i]
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _emoji == _emojis[i]
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(_emojis[i],
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date / Time / Location row
          Row(
            children: [
              _InfoButton(
                icon: Icons.calendar_today_outlined,
                label: _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}'
                    : 'Ngày',
                onTap: _pickDate,
              ),
              const SizedBox(width: 8),
              _InfoButton(
                icon: Icons.access_time_outlined,
                label: _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Giờ',
                onTap: _pickTime,
              ),
              const SizedBox(width: 8),
              _InfoButton(
                icon: Icons.location_on_outlined,
                label: _location ?? 'Địa điểm',
                onTap: () async {
                  final ctrl = TextEditingController(text: _location);
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Địa điểm'),
                      content: TextField(controller: ctrl),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() => _location = ctrl.text.isNotEmpty
                                ? ctrl.text
                                : null);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Priority matrix selector
          const Text(
            'Mức độ ưu tiên',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: PriorityLevel.values.map((lvl) {
              final isSelected = _priority == lvl;
              final color = _priorityColor(lvl);
              final label = _priorityLabel(lvl);
              return GestureDetector(
                onTap: () => setState(() => _priority = lvl),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Thêm công việc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(PriorityLevel lvl) => switch (lvl) {
        PriorityLevel.level1 => AppColors.level1,
        PriorityLevel.level2 => AppColors.level2,
        PriorityLevel.level3 => AppColors.level3,
        PriorityLevel.level4 => AppColors.level4,
      };

  String _priorityLabel(PriorityLevel lvl) => switch (lvl) {
        PriorityLevel.level1 => 'Cấp 1 — Khẩn cấp',
        PriorityLevel.level2 => 'Cấp 2 — Quan trọng',
        PriorityLevel.level3 => 'Cấp 3 — Thường',
        PriorityLevel.level4 => 'Cấp 4 — Thấp',
      };
}

class _InfoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _InfoButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
