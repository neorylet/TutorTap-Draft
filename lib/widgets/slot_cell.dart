import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum SlotCellState { available, selected, locked, taken }

class SlotCell extends StatelessWidget {
  const SlotCell({
    super.key,
    required this.label,
    required this.state,
    this.holdLabel,
    this.onTap,
  });

  final String label;
  final SlotCellState state;
  final String? holdLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Color border) = switch (state) {
      SlotCellState.available => (
        AppColors.white,
        AppColors.forest,
        AppColors.mint,
      ),
      SlotCellState.selected => (
        AppColors.emerald,
        AppColors.white,
        AppColors.emerald,
      ),
      SlotCellState.locked => (
        AppColors.amberBg,
        const Color(0xFF80500E),
        AppColors.amber,
      ),
      SlotCellState.taken => (
        AppColors.sage,
        AppColors.muted,
        AppColors.border,
      ),
    };

    return GestureDetector(
      onTap: state == SlotCellState.taken ? null : onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: border,
            width: state == SlotCellState.locked ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontSize: 11,
                decoration: state == SlotCellState.taken
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            if (holdLabel != null && holdLabel!.isNotEmpty)
              Text(
                holdLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontSize: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
