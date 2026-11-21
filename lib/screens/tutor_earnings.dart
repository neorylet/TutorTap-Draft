import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorEarningsScreen extends StatefulWidget {
  const TutorEarningsScreen({super.key});

  @override
  State<TutorEarningsScreen> createState() => _TutorEarningsScreenState();
}

class _TutorEarningsScreenState extends State<TutorEarningsScreen> {
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
    final List<Booking> paid = _bookings
        .where(
          (Booking booking) =>
              booking.status == BookingStatus.confirmed ||
              booking.status == BookingStatus.completed,
        )
        .toList(growable: false);
    final double payout = paid.fold<double>(
      0,
      (double sum, Booking booking) => sum + booking.tutorPayout,
    );
    final double commission = paid.fold<double>(
      0,
      (double sum, Booking booking) => sum + booking.commissionAmount,
    );

    return ScreenScaffold(
      title: 'Earnings',
      subtitle: 'Commission is calculated on every confirmed session.',
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(label: 'Tutor payout', value: '₱${payout.toStringAsFixed(2)}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Platform fee',
                  value: '₱${commission.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Recent sessions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Expanded(
            child: paid.isEmpty
                ? const EmptyHint(message: 'No confirmed earnings yet.')
                : ListView.builder(
                    itemCount: paid.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Booking booking = paid[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SectionCard(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(booking.studentName),
                                    const SizedBox(height: 3),
                                    Text(
                                      DateFormat('d MMM · h:mm a')
                                          .format(booking.slotStart),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text('₱${booking.tutorPayout.toStringAsFixed(2)}'),
                                  const SizedBox(height: 3),
                                  StatusBadge.fromStatus(booking.status.value),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

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
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
