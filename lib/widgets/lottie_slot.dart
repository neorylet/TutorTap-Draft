import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../core/theme/app_colors.dart';

class LottieSlot extends StatelessWidget {
  const LottieSlot({
    super.key,
    required this.asset,
    this.height = 220,
    this.caption,
    this.compact = false,
    this.loop = true,
  });

  final String asset;
  final double height;
  final String? caption;
  final bool compact;
  final bool loop;

  @override
  Widget build(BuildContext context) {
    final bool animationsEnabled = !MediaQuery.disableAnimationsOf(context);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.sage,
        border: Border.all(color: AppColors.emerald, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Lottie.asset(
        asset,
        animate: animationsEnabled,
        repeat: loop && animationsEnabled,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, Object exception, StackTrace? stack) {
          return _fallback(context);
        },
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: compact ? 34 : 42,
          height: compact ? 34 : 42,
          decoration: const BoxDecoration(
            color: AppColors.emerald,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
        ),
        if (!compact) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            caption ?? 'Animation placeholder',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}
