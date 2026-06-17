import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_ai/core/constants/app_colors.dart';
import 'package:flutter_application_ai/presentation/providers/task_provider.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';

// ── Providers ──────────────────────────────────────────────────────────────
class ScheduleDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime d) => state = d;
}

final scheduleSelectedDateProvider =
    NotifierProvider<ScheduleDateNotifier, DateTime>(ScheduleDateNotifier.new);

final scheduleDayTasksProvider = Provider<List<Task>>((ref) {
  final date = ref.watch(scheduleSelectedDateProvider);
  final tasks = ref.watch(taskListProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <Task>[],
  );
  return tasks.where((t) {
    if (t.dueDate == null) return false;
    return t.dueDate!.year == date.year &&
        t.dueDate!.month == date.month &&
        t.dueDate!.day == date.day;
  }).toList();
});

// ── Screen ─────────────────────────────────────────────────────────────────
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(scheduleSelectedDateProvider);
    final tasks = ref.watch(scheduleDayTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lịch trình',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(selected),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref
                        .read(scheduleSelectedDateProvider.notifier)
                        .set(DateTime.now()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Hôm nay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Week strip
            _WeekStrip(
              selected: selected,
              onDateSelected: (d) =>
                  ref.read(scheduleSelectedDateProvider.notifier).set(d),
            ),

            const SizedBox(height: 16),

            // Timeline
            Expanded(
              child: _TimelineView(tasks: tasks, selectedDate: selected),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week Strip ─────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekStrip(
      {required this.selected, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(const Duration(days: 3));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: days.map((day) {
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          final isToday = day.year == DateTime.now().year &&
              day.month == DateTime.now().month &&
              day.day == DateTime.now().day;

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayLabels[day.weekday % 7],
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Timeline View ──────────────────────────────────────────────────────────
class _TimelineView extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDate;

  const _TimelineView({required this.tasks, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    const startHour = 6;
    const endHour = 23;
    const hourHeight = 72.0;
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: (endHour - startHour) * hourHeight + 60,
        child: Stack(
          children: [
            // Hour lines
            ...List.generate(endHour - startHour, (i) {
              final hour = startHour + i;
              return Positioned(
                top: i * hourHeight,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.border,
                        margin: const EdgeInsets.only(top: 6),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Current time indicator
            if (selectedDate.year == now.year &&
                selectedDate.month == now.month &&
                selectedDate.day == now.day)
              Positioned(
                top: (now.hour - startHour) * hourHeight +
                    (now.minute / 60.0 * hourHeight),
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const SizedBox(width: 52),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                    ),
                    Expanded(
                        child: Container(height: 2, color: AppColors.error)),
                  ],
                ),
              ),

            // Task cards
            ...tasks.where((t) => t.dueTimeStr != null).map((task) {
              final parts = task.dueTimeStr!.split(':');
              final hour = int.tryParse(parts[0]) ?? startHour;
              final minute =
                  int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
              final top = (hour - startHour) * hourHeight +
                  (minute / 60.0 * hourHeight);

              return Positioned(
                top: top,
                left: 60,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (task.emoji != null)
                        Text(task.emoji!,
                            style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.location != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 10, color: Colors.white70),
                                  const SizedBox(width: 2),
                                  Text(
                                    task.location!,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 10),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Text(
                        task.dueTimeStr!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
