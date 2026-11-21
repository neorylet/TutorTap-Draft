import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum StatusTone { neutral, positive, warning, negative }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = StatusTone.neutral});

  factory StatusBadge.fromStatus(String status) {
    final String normalized = status.toLowerCase();
    final StatusTone tone = switch (normalized) {
      'confirmed' || 'verified' || 'online' || 'submitted' || 'graded' => StatusTone.positive,
      'pending' || 'assigned' || 'new' || 'simulated' => StatusTone.warning,
      'cancelled' || 'rejected' => StatusTone.negative,
      _ => StatusTone.neutral,
    };
    return StatusBadge(label: status, tone: tone);
  }

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (tone) {
      StatusTone.neutral => (AppColors.sage, AppColors.forest),
      StatusTone.positive => (AppColors.mint, AppColors.emerald),
      StatusTone.warning => (AppColors.amberBg, const Color(0xFF815412)),
      StatusTone.negative => (AppColors.brickBg, AppColors.brick),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontSize: 10,
        ),
      ),
    );
  }
}
