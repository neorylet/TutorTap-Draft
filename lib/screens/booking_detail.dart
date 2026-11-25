import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/meeting_link_box.dart';
import '../widgets/pill_button.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _completing = false;

  Future<void> _markComplete(Booking booking) async {
    if (_completing) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Mark session complete?'),
        content: const Text(
          'Earnings are recorded immediately and this cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Mark complete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _completing = true);
    final BookingProvider provider = context.read<BookingProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final bool ok = await provider.completeBooking(booking);
    if (!mounted) return;
    setState(() => _completing = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Session marked complete.'
              : provider.error ?? 'Could not complete session.',
        ),
      ),
    );
    if (ok) navigator.pop();
  }

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

    final String? uid = context.select<AuthProvider, String?>(
      (AuthProvider p) => p.currentUser?.uid,
    );
    final bool isTutor = uid == booking.tutorId;
    final bool canModify =
        booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.pending;

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
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, d MMMM').format(booking.slotStart),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      StatusBadge.fromStatus(booking.status.value),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('h:mm a').format(booking.slotStart)} – ${DateFormat('h:mm a').format(booking.slotEnd)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (booking.isCompleted && booking.completedAt != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Completed on ${DateFormat('d MMM, h:mm a').format(booking.completedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
                  _Row(
                    label: 'Total charged',
                    value: '₱${booking.totalCharged.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 6),
                  _Row(
                    label: 'Commission',
                    value: '₱${booking.commissionAmount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 6),
                  _Row(
                    label: 'Tutor payout',
                    value: '₱${booking.tutorPayout.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 6),
                  _Row(label: 'Payment mode', value: booking.paymentMode),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isTutor && booking.canBeCompleted) ...<Widget>[
              PillButton(
                label: _completing ? 'Saving…' : 'Mark session complete',
                onPressed: _completing ? null : () => _markComplete(booking),
              ),
              const SizedBox(height: 8),
            ],
            if (!booking.isCompleted) ...<Widget>[
              PillButton(
                label: 'Reschedule',
                variant: PillButtonVariant.secondary,
                onPressed: !canModify
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
                onPressed: !canModify
                    ? null
                    : () async {
                        await context
                            .read<BookingProvider>()
                            .cancelBooking(booking);
                        if (context.mounted) Navigator.of(context).pop();
                      },
              ),
            ],
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
