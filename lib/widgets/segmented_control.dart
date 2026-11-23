import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
    this.scrollable = false,
  });

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelBuilder;
  final bool scrollable;

  Widget _item(BuildContext context, T item) {
    final bool selected = item == value;
    return GestureDetector(
      onTap: () => onChanged(item),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: scrollable
            ? const EdgeInsets.symmetric(horizontal: 12)
            : EdgeInsets.zero,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: selected ? AppColors.emerald : AppColors.muted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = values
        .map((T item) => _item(context, item))
        .toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sage,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: items),
            )
          : Row(
              children: items
                  .map((Widget item) => Expanded(child: item))
                  .toList(growable: false),
            ),
    );
  }
}
