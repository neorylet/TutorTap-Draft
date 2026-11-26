import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../models/time_slot.dart';
import '../providers/booking_provider.dart';
import '../widgets/pill_button.dart';
import '../widgets/reschedule_confirm_sheet.dart';
import '../widgets/slot_cell.dart';
import 'screen_scaffold.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  bool _initialized = false;
  TimeSlot? _selectedSlot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final Booking? booking =
        ModalRoute.of(context)?.settings.arguments as Booking?;
    if (booking != null) {
      context.read<BookingProvider>().watchTutorSlots(booking.tutorId);
    }
  }

  String _slotRange(DateTime start, DateTime end) =>
      '${DateFormat('EEE d MMM · h:mm a').format(start)} – ${DateFormat('h:mm a').format(end)}';

  Future<void> _confirm(Booking booking) async {
    final TimeSlot? selected = _selectedSlot;
    if (selected == null) return;
    final NavigatorState navigator = Navigator.of(context);
    final bool confirmed = await showRescheduleConfirmSheet(
      context,
      booking: booking,
      newSlot: selected,
    );
    if (!confirmed || !mounted) return;
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final Booking? booking =
        ModalRoute.of(context)?.settings.arguments as Booking?;
    if (booking == null) {
      return const ScreenScaffold(
        title: 'Reschedule',
        body: EmptyHint(message: 'No booking to reschedule.'),
      );
    }
    final List<TimeSlot> slots = context
        .select<BookingProvider, List<TimeSlot>>(
          (BookingProvider provider) => provider.slots,
        );
    final DateTime now = DateTime.now();
    final List<TimeSlot> available = slots.where((TimeSlot slot) {
      return slot.start.isAfter(now) &&
          slot.bookedBy == null &&
          !slot.start.isAtSameMomentAs(booking.slotStart);
    }).toList(growable: false);

    return ScreenScaffold(
      title: 'Reschedule',
      subtitle: 'Pick a new time with ${booking.tutorName}.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Current session',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _slotRange(booking.slotStart, booking.slotEnd),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: available.isEmpty
                ? const EmptyHint(message: 'No other slots are open right now.')
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.map((TimeSlot slot) {
                        return SizedBox(
                          width: 112,
                          child: SlotCell(
                            label: DateFormat('EEE d MMM\nh:mm a')
                                .format(slot.start),
                            state: slot.id == _selectedSlot?.id
                                ? SlotCellState.selected
                                : SlotCellState.available,
                            onTap: () => setState(() => _selectedSlot = slot),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ),
          ),
          if (_selectedSlot != null) ...<Widget>[
            const SizedBox(height: 12),
            PillButton(
              label: 'Move to ${_slotRange(_selectedSlot!.start, _selectedSlot!.end)}',
              onPressed: () => _confirm(booking),
            ),
          ],
        ],
      ),
    );
  }
}
