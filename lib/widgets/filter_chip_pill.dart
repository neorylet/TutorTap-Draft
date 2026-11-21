import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        constraints: const BoxConstraints(minHeight: 34),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.emerald : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: 13,
                color: selected ? AppColors.white : AppColors.muted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.white : AppColors.forest,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
