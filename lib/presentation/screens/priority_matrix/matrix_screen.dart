import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/core/constants/app_colors.dart';
import 'package:flutter_application_ai/presentation/providers/task_provider.dart';
import 'package:flutter_application_ai/domain/enums/priority_level.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';

class MatrixScreen extends ConsumerWidget {
  const MatrixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matrix = ref.watch(matrixTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ma trận',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ưu tiên',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ma trận Eisenhower phân loại công việc',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _QuadrantCard(
                      title: 'Cấp độ 1',
                      subtitle: 'Quan trọng & Khẩn cấp',
                      color: AppColors.level1,
                      tasks: matrix[PriorityLevel.level1] ?? [],
                    ),
                    _QuadrantCard(
                      title: 'Cấp độ 2',
                      subtitle: 'Quan trọng, không khẩn cấp',
                      color: AppColors.level2,
                      tasks: matrix[PriorityLevel.level2] ?? [],
                    ),
                    _QuadrantCard(
                      title: 'Cấp độ 3',
                      subtitle: 'Không quan trọng, khẩn cấp',
                      color: AppColors.level3,
                      tasks: matrix[PriorityLevel.level3] ?? [],
                    ),
                    _QuadrantCard(
                      title: 'Cấp độ 4',
                      subtitle: 'Không quan trọng, không khẩn cấp',
                      color: AppColors.level4,
                      tasks: matrix[PriorityLevel.level4] ?? [],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuadrantCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final List<Task> tasks;

  const _QuadrantCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
              maxLines: 2),
          const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text('Trống',
                        style: TextStyle(
                            fontSize: 11,
                            color: color.withValues(alpha: 0.5))),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length > 4 ? 4 : tasks.length,
                    itemBuilder: (context, i) {
                      final isOverflow = i == 3 && tasks.length > 4;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: isOverflow
                            ? Text(
                                '+ ${tasks.length - 3} công việc khác',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600),
                              )
                            : Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: color, width: 1.5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      tasks[i].title,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
