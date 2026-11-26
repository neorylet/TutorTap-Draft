import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/reschedule_reasons.dart';
import '../core/theme/app_colors.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';
import '../providers/booking_provider.dart';
import '../screens/screen_scaffold.dart';
import 'filter_chip_pill.dart';
import 'pill_button.dart';

Future<bool> showRescheduleConfirmSheet(
  BuildContext context, {
  required Booking booking,
  required TimeSlot newSlot,
}) async {
  final bool? confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _RescheduleConfirmSheet(
      booking: booking,
      newSlot: newSlot,
    ),
  );
  return confirmed ?? false;
}

class _RescheduleConfirmSheet extends StatefulWidget {
  const _RescheduleConfirmSheet({required this.booking, required this.newSlot});

  final Booking booking;
  final TimeSlot newSlot;

  @override
  State<_RescheduleConfirmSheet> createState() =>
      _RescheduleConfirmSheetState();
}

class _RescheduleConfirmSheetState extends State<_RescheduleConfirmSheet> {
  String? _reason;
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _slotRange(DateTime start, DateTime end) =>
      '${DateFormat('EEE d MMM · h:mm a').format(start)} – ${DateFormat('h:mm a').format(end)}';

  Future<void> _submit() async {
    if (_reason == null || _submitting) return;
    final String reason = _reason!;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final NavigatorState navigator = Navigator.of(context);
    final BookingProvider provider = context.read<BookingProvider>();
    final bool ok = await provider.rescheduleBooking(
      booking: widget.booking,
      newSlotId: widget.newSlot.id,
      newStart: widget.newSlot.start,
      newEnd: widget.newSlot.end,
      reason: reason,
      note: _noteController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _submitting = false;
      _error = provider.error ?? 'Could not reschedule.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Reschedule session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'From',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _slotRange(widget.booking.slotStart, widget.booking.slotEnd),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'To',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _slotRange(widget.newSlot.start, widget.newSlot.end),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Same tutor and duration. No charge — your payment carries over.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'Reason (required)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RescheduleReasons.all
                  .map(
                    (RescheduleReason r) => FilterChipPill(
                      label: r.label,
                      selected: _reason == r.code,
                      onTap: _submitting
                          ? null
                          : () => setState(() => _reason = r.code),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
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
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 14),
            PillButton(
              label: 'Cancel',
              variant: PillButtonVariant.secondary,
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PillButton(
                  label: _submitting ? '' : 'Confirm reschedule',
                  onPressed:
                      _reason == null || _submitting ? null : _submit,
                ),
                if (_submitting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.emerald,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
