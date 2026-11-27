import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../core/constants/cancellation_reasons.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../services/firestore_service.dart';
import '../widgets/pill_button.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  StreamSubscription<List<Booking>>? _subscription;
  List<Booking> _bookings = <Booking>[];
  bool _initialized = false;
  final Set<String> _completing = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      _subscription = context
          .read<FirestoreService>()
          .watchBookingsForTutor(uid)
          .listen((List<Booking> bookings) {
        if (mounted) setState(() => _bookings = bookings);
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _markComplete(Booking booking) async {
    if (_completing.contains(booking.id)) return;
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
    setState(() => _completing.add(booking.id));
    final BookingProvider provider = context.read<BookingProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool ok = await provider.completeBooking(booking);
    if (!mounted) return;
    setState(() => _completing.remove(booking.id));
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Session marked complete.'
              : provider.error ?? 'Could not complete session.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final List<Booking> upcoming = _bookings
        .where((Booking b) => b.isUpcoming)
        .toList(growable: false)
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart));
    final List<Booking> past = _bookings
        .where((Booking b) => !b.isUpcoming)
        .toList(growable: false)
      ..sort((a, b) => b.slotStart.compareTo(a.slotStart));
    final double earned = _bookings
        .where((Booking b) => b.isCompleted)
        .fold<double>(0, (double sum, Booking b) => sum + b.tutorPayout);

    return ScreenScaffold(
      title: 'Hi, ${user?.displayName.split(' ').first ?? 'tutor'}',
      subtitle: 'Your teaching hub.',
      showBack: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    label: 'Active sessions',
                    value: '${upcoming.length}',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Earned',
                    value: '₱${earned.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ActionChip(
                  label: const Text('Availability'),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.tutorAvailability),
                ),
                ActionChip(
                  label: const Text('Students'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.tutorStudents),
                ),
                ActionChip(
                  label: const Text('Earnings'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.tutorEarnings),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (upcoming.isEmpty)
              const EmptyHint(message: 'No upcoming sessions.')
            else
              ...upcoming.take(5).map(
                    (Booking booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.bookingDetail,
                          arguments: booking,
                        ),
                        child: SectionCard(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(booking.studentName),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('EEE d MMM · h:mm a')
                                          .format(booking.slotStart),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    if (booking.isRescheduled) ...<Widget>[
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.rescheduleSummary,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              StatusBadge.fromStatus(booking.status.value),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            Text('Past', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (past.isEmpty)
              const EmptyHint(message: 'No past sessions.')
            else
              ...past.map(
                (Booking booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.bookingDetail,
                      arguments: booking,
                    ),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(booking.studentName),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEE d MMM · h:mm a')
                                      .format(booking.slotStart),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (booking.canBeCompleted)
                            TextButton(
                              onPressed: _completing.contains(booking.id)
                                  ? null
                                  : () => _markComplete(booking),
                              child: Text(
                                _completing.contains(booking.id)
                                    ? 'Saving…'
                                    : 'Mark complete',
                              ),
                            )
                          else if (booking.isCancelled)
                            Text(
                              CancellationReasons.labelFor(
                                booking.cancellationReason,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            StatusBadge.fromStatus(booking.status.value),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            PillButton(
              label: 'Open classroom',
              variant: PillButtonVariant.secondary,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.tutorClassroom),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
