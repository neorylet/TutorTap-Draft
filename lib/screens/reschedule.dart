import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../models/time_slot.dart';
import '../providers/booking_provider.dart';
import '../widgets/slot_cell.dart';
import 'screen_scaffold.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  bool _initialized = false;

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
    final List<TimeSlot> slots = context.select<BookingProvider, List<TimeSlot>>(
      (BookingProvider provider) => provider.slots,
    );
    final DateTime now = DateTime.now();
    final List<TimeSlot> available = slots.where((TimeSlot slot) {
      return slot.isAvailable(now) &&
          !slot.start.isAtSameMomentAs(booking.slotStart);
    }).toList(growable: false);

    return ScreenScaffold(
      title: 'Reschedule',
      subtitle: 'Pick a new time with ${booking.tutorName}.',
      body: available.isEmpty
          ? const EmptyHint(message: 'No other slots are open right now.')
          : SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: available.map((TimeSlot slot) {
                  return SizedBox(
                    width: 112,
                    child: SlotCell(
                      label: DateFormat('EEE d MMM\nh:mm a').format(slot.start),
                      state: SlotCellState.available,
                      onTap: () => _reschedule(booking, slot),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
    );
  }

  Future<void> _reschedule(Booking booking, TimeSlot slot) async {
    final BookingProvider bookingProvider = context.read<BookingProvider>();
    await bookingProvider.rescheduleBooking(
      booking: booking,
      newSlotId: slot.id,
      newStart: slot.start,
      newEnd: slot.end,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
