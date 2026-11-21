import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum PillButtonVariant { primary, secondary, text, amber }

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PillButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.minHeight = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, BorderSide side) = switch (variant) {
      PillButtonVariant.primary => (
        AppColors.emerald,
        AppColors.white,
        BorderSide.none,
      ),
      PillButtonVariant.secondary => (
        AppColors.transparent,
        AppColors.emerald,
        const BorderSide(color: AppColors.emerald),
      ),
      PillButtonVariant.text => (
        AppColors.transparent,
        AppColors.emerald,
        BorderSide.none,
      ),
      PillButtonVariant.amber => (
        AppColors.amberBg,
        const Color(0xFF7B4E12),
        const BorderSide(color: AppColors.amber),
      ),
    };

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.sage,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          side: side,
          minimumSize: Size(0, minHeight),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
