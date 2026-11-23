import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/screen_scaffold.dart';

class DueDateTile extends StatelessWidget {
  const DueDateTile({
    super.key,
    required this.dueDate,
    required this.onChanged,
    this.isRequired = true,
    this.isBusy = false,
  });

  final DateTime? dueDate;
  final ValueChanged<DateTime?> onChanged;
  final bool isRequired;
  final bool isBusy;

  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = dueDate != null && dueDate!.isAfter(now)
        ? dueDate!
        : now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, now.month, now.day),
    );
    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null || !context.mounted) return;

    final DateTime newDueDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (newDueDate.isBefore(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Due date must be in the future.')),
        );
      }
      return;
    }

    onChanged(newDueDate);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: <Widget>[
          const Icon(Icons.event_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isRequired ? 'Due date' : 'Deadline (optional)',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  dueDate != null
                      ? DateFormat('d MMM, h:mm a').format(dueDate!)
                      : 'No deadline',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (dueDate != null)
            TextButton(
              onPressed: isBusy ? null : () => _pickDueDate(context),
              child: const Text('Change'),
            )
          else
            TextButton(
              onPressed: isBusy ? null : () => _pickDueDate(context),
              child: const Text('Set'),
            ),
          if (!isRequired && dueDate != null)
            TextButton(
              onPressed: isBusy ? null : () => onChanged(null),
              child: const Text('Clear deadline'),
            ),
        ],
      ),
    );
  }
}
