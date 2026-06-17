import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/presentation/providers/task_provider.dart';
import 'package:flutter_application_ai/presentation/providers/category_provider.dart';
import 'package:flutter_application_ai/presentation/shared/components/task_tile.dart';
import 'package:flutter_application_ai/presentation/shared/dialogs/add_task_bottom_sheet.dart';
import 'package:flutter_application_ai/core/constants/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'TodoTick',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _IconBtn(icon: Icons.search, onTap: () {}),
                  const SizedBox(width: 8),
                  _IconBtn(icon: Icons.more_horiz, onTap: () {}),
                ],
              ),
            ),

            // ── Category Tab Bar ──────────────────────────────────────
            categoriesAsync.when(
              data: (cats) => SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cats.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == cats.length) {
                      return _CategoryChip(
                        label: '+',
                        isSelected: false,
                        color: AppColors.border,
                        onTap: () {},
                      );
                    }
                    final cat = cats[index];
                    final isSelected = (selectedCategory == null &&
                            cat.id == 'all') ||
                        selectedCategory == cat.id;
                    return _CategoryChip(
                      label: cat.name,
                      isSelected: isSelected,
                      color: Color(cat.colorValue),
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .select(cat.id == 'all' ? null : cat.id),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 44),
              error: (_, __) => const SizedBox(height: 44),
            ),

            const SizedBox(height: 12),

            // ── Filter chips ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Hôm nay',
                    isSelected: selectedFilter == TaskFilter.today,
                    onTap: () =>
                        ref.read(taskFilterProvider.notifier).set(TaskFilter.today),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Tuần này',
                    isSelected: selectedFilter == TaskFilter.week,
                    onTap: () =>
                        ref.read(taskFilterProvider.notifier).set(TaskFilter.week),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected: selectedFilter == TaskFilter.all,
                    onTap: () =>
                        ref.read(taskFilterProvider.notifier).set(TaskFilter.all),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Task List ─────────────────────────────────────────────
            Expanded(
              child: tasks.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskTile(
                          task: task,
                          onToggle: () => ref
                              .read(taskListProvider.notifier)
                              .toggleComplete(task.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddTaskBottomSheet(),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Local Widgets ──────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.label,
      required this.isSelected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: isSelected ? color : AppColors.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('🎉', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text(
            'Không có công việc nào!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nhấn + để thêm công việc mới',
            style:
                TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
