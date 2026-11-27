import 'package:flutter/material.dart';

import '../core/constants/cancellation_reasons.dart';
import 'pill_button.dart';

Future<({String reason, String note})?> showCancelBookingSheet(
  BuildContext context, {
  required bool isTutor,
}) {
  return showModalBottomSheet<({String reason, String note})>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _CancelBookingSheet(isTutor: isTutor),
  );
}

class _CancelBookingSheet extends StatefulWidget {
  const _CancelBookingSheet({required this.isTutor});

  final bool isTutor;

  @override
  State<_CancelBookingSheet> createState() => _CancelBookingSheetState();
}

class _CancelBookingSheetState extends State<_CancelBookingSheet> {
  String? _reason;
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CancellationReason> reasons = widget.isTutor
        ? CancellationReasons.tutor
        : CancellationReasons.student;
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Cancel this session?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _reason,
              onChanged: _submitting
                  ? (String? _) {}
                  : (String? v) => setState(() => _reason = v),
              child: Column(
                children: reasons
                    .map(
                      (CancellationReason r) => RadioListTile<String>(
                        value: r.code,
                        contentPadding: EdgeInsets.zero,
                        title: Text(r.label),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            TextField(
              controller: _noteController,
              maxLength: 200,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The slot is released immediately and the other person will see your reason. This cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            PillButton(
              label: _submitting ? 'Cancelling…' : 'Cancel session',
              variant: PillButtonVariant.amber,
              onPressed: _reason == null || _submitting
                  ? null
                  : () {
                      setState(() => _submitting = true);
                      Navigator.of(context).pop((
                        reason: _reason!,
                        note: _noteController.text.trim(),
                      ));
                    },
            ),
            const SizedBox(height: 8),
            PillButton(
              label: 'Keep booking',
              variant: PillButtonVariant.secondary,
              onPressed:
                  _submitting ? null : () => Navigator.of(context).pop(null),
            ),
          ],
        ),
      ),
    );
  }
}
