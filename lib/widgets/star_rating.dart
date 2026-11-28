import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.size = 16,
    this.onChanged,
  });

  final double value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final int filled = value.round().clamp(0, 5).toInt();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int star = 1; star <= 5; star++)
          if (onChanged == null)
            Icon(
              star <= filled ? Icons.star : Icons.star_border,
              size: size,
              color: AppColors.amber,
            )
          else
            IconButton(
              icon: Icon(
                star <= filled ? Icons.star : Icons.star_border,
                size: size,
                color: AppColors.amber,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Rate $star star${star > 1 ? 's' : ''}',
              onPressed: () => onChanged!(star),
            ),
      ],
    );
  }
}
