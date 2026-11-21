import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
  });

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sage,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: values.map((T item) {
          final bool selected = item == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.white : AppColors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: selected
                      ? const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labelBuilder(item),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? AppColors.emerald : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
