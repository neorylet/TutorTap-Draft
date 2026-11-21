import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/booking.dart';
import '../routing/app_routes.dart';
import '../widgets/lottie_slot.dart';
import '../widgets/meeting_link_box.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

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

    return ScreenScaffold(
      title: 'You are booked!',
      subtitle: 'A confirmation was saved to your bookings.',
      showBack: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const LottieSlot(
              asset: AppConstants.lottieBookingSuccess,
              height: 170,
              caption: 'See you in class',
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    booking.tutorName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('EEE d MMM · h:mm a').format(booking.slotStart),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  MeetingLinkBox(
                    link: booking.onlineSession.link,
                    room: booking.onlineSession.room,
                    note: booking.onlineSession.note,
                  ),
                  const SizedBox(height: 12),
                  _Detail(
                    label: 'Paid',
                    value: '₱${booking.totalCharged.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 4),
                  _Detail(label: 'Payment', value: booking.paymentMode),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PillButton(
              label: 'View bookings',
              onPressed: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.bookings),
            ),
            const SizedBox(height: 8),
            PillButton(
              label: 'Back to home',
              variant: PillButtonVariant.text,
              onPressed: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.studentHome),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

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
