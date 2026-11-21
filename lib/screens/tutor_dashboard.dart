import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final List<Booking> active = _bookings
        .where(
          (Booking booking) =>
              booking.status == BookingStatus.confirmed ||
              booking.status == BookingStatus.pending,
        )
        .toList(growable: false);
    final double payout = _bookings.fold<double>(
      0,
      (double sum, Booking booking) => sum + booking.tutorPayout,
    );

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
                    value: '${active.length}',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Tutor payout',
                    value: '₱${payout.toStringAsFixed(0)}',
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
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.tutorStudents),
                ),
                ActionChip(
                  label: const Text('Earnings'),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.tutorEarnings),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (_bookings.isEmpty)
              const EmptyHint(message: 'No bookings yet.')
            else
              ...active.take(5).map(
                (Booking booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
                        StatusBadge.fromStatus(booking.status.value),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            PillButton(
              label: 'Open classroom',
              variant: PillButtonVariant.secondary,
              onPressed: () => Navigator.of(context)
                  .pushNamed(AppRoutes.tutorClassroom),
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
