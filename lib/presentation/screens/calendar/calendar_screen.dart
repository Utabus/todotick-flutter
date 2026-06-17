import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_ai/core/constants/app_colors.dart';
import 'package:flutter_application_ai/presentation/providers/task_provider.dart';
import 'package:flutter_application_ai/presentation/shared/components/task_tile.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';

// ── Providers ──────────────────────────────────────────────────────────────
class CalendarDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime d) => state = d;
}

class CalendarFocusNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime d) => state = d;
}

final calendarSelectedDayProvider =
    NotifierProvider<CalendarDayNotifier, DateTime>(CalendarDayNotifier.new);

final calendarFocusedDayProvider =
    NotifierProvider<CalendarFocusNotifier, DateTime>(
        CalendarFocusNotifier.new);

// ── Screen ─────────────────────────────────────────────────────────────────
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(calendarSelectedDayProvider);
    final focused = ref.watch(calendarFocusedDayProvider);
    final allTasks = ref.watch(taskListProvider).maybeWhen(
          data: (d) => d,
          orElse: () => <Task>[],
        );

    // Group tasks by date
    final Map<DateTime, List<Task>> tasksByDay = {};
    for (final t in allTasks) {
      if (t.dueDate == null) continue;
      final key = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      (tasksByDay[key] ??= []).add(t);
    }

    final selectedKey =
        DateTime(selected.year, selected.month, selected.day);
    final dayTasks = tasksByDay[selectedKey] ?? [];

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
                  const Text(
                    'Lịch',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMMM yyyy').format(focused),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Calendar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focused,
                selectedDayPredicate: (day) => isSameDay(day, selected),
                eventLoader: (day) {
                  final key =
                      DateTime(day.year, day.month, day.day);
                  return tasksByDay[key] ?? [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  ref
                      .read(calendarSelectedDayProvider.notifier)
                      .set(selectedDay);
                  ref
                      .read(calendarFocusedDayProvider.notifier)
                      .set(focusedDay);
                },
                onPageChanged: (focusedDay) {
                  ref
                      .read(calendarFocusedDayProvider.notifier)
                      .set(focusedDay);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerSize: 5,
                  markersMaxCount: 3,
                  weekendTextStyle: const TextStyle(color: AppColors.error),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  weekendStyle: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    isSameDay(selected, DateTime.now())
                        ? 'Hôm nay'
                        : DateFormat('dd MMMM').format(selected),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dayTasks.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: dayTasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📭', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 8),
                          Text(
                            'Không có công việc',
                            style: TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dayTasks.length,
                      itemBuilder: (context, index) =>
                          TaskTile(task: dayTasks[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
