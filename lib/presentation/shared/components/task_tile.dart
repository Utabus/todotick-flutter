import 'package:flutter/material.dart';
import 'package:flutter_application_ai/core/constants/app_colors.dart';
import 'package:flutter_application_ai/domain/entities/task.dart';
import 'package:flutter_application_ai/domain/enums/task_status.dart';
import 'package:flutter_application_ai/domain/enums/priority_level.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _priorityColor {
    return switch (widget.task.priority) {
      PriorityLevel.level1 => AppColors.level1,
      PriorityLevel.level2 => AppColors.level2,
      PriorityLevel.level3 => AppColors.level3,
      PriorityLevel.level4 => AppColors.level4,
    };
  }

  bool get _isDone => widget.task.status == TaskStatus.done;

  void _handleToggle() {
    _controller.forward(from: 0);
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isDone ? Colors.white.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isDone
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: _isDone
              ? Border.all(color: AppColors.border, width: 1)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox with bounce animation
            GestureDetector(
              onTap: _handleToggle,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isDone ? _priorityColor : Colors.transparent,
                    border: Border.all(
                      color: _priorityColor,
                      width: 2,
                    ),
                  ),
                  child: _isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: _isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    child: Text(
                      widget.task.emoji != null
                          ? '${widget.task.emoji} ${widget.task.title}'
                          : widget.task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.task.dueDate != null) ...[
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('dd/MM').format(widget.task.dueDate!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (widget.task.dueTimeStr != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.access_time_outlined,
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            widget.task.dueTimeStr!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                      if (widget.task.location != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: AppColors.error),
                        const SizedBox(width: 2),
                        Text(
                          widget.task.location!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Priority dot
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _priorityColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
