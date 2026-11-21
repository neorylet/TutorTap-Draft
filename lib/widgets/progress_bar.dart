import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.label,
    this.caption,
  });

  final double value;
  final String? label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final double progress = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null || caption != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (label != null)
                  Text(label!, style: Theme.of(context).textTheme.bodySmall),
                if (caption != null)
                  Text(caption!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.sage,
            color: AppColors.emerald,
          ),
        ),
      ],
    );
  }
}
