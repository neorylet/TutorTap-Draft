import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/meeting_link_box.dart';
import '../widgets/pill_button.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Booking? booking =
        ModalRoute.of(context)?.settings.arguments as Booking?;
    if (booking == null) {
      return const ScreenScaffold(
        title: 'Booking',
        body: EmptyHint(message: 'No booking to show.'),
      );
    }

    final bool isCancelled = booking.status.name == 'cancelled';

    return ScreenScaffold(
      title: booking.tutorName,
      subtitle: booking.subject,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        DateFormat('EEEE, d MMMM').format(booking.slotStart),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      StatusBadge.fromStatus(booking.status.value),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('h:mm a').format(booking.slotStart)} – ${DateFormat('h:mm a').format(booking.slotEnd)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  MeetingLinkBox(
                    link: booking.onlineSession.link,
                    room: booking.onlineSession.room,
                    note: booking.onlineSession.note,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: <Widget>[
                  _Row(label: 'Total charged', value: '₱${booking.totalCharged.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _Row(label: 'Commission', value: '₱${booking.commissionAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _Row(label: 'Tutor payout', value: '₱${booking.tutorPayout.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _Row(label: 'Payment mode', value: booking.paymentMode),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PillButton(
              label: 'Reschedule',
              variant: PillButtonVariant.secondary,
              onPressed: isCancelled
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        AppRoutes.reschedule,
                        arguments: booking,
                      ),
            ),
            const SizedBox(height: 8),
            PillButton(
              label: 'Cancel booking',
              variant: PillButtonVariant.text,
              onPressed: isCancelled
                  ? null
                  : () async {
                      await context.read<BookingProvider>().cancelBooking(booking.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
