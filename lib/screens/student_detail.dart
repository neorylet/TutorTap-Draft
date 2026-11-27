import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  StreamSubscription<List<Booking>>? _subscription;
  List<Booking> _bookings = <Booking>[];
  bool _loaded = false;
  bool _initialized = false;
  String _studentId = '';
  String _studentName = 'Student';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> map = arguments is Map<String, dynamic>
        ? arguments
        : <String, dynamic>{};
    _studentId = map['studentId'] as String? ?? '';
    _studentName = map['studentName'] as String? ?? 'Student';

    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      _subscription = context
          .read<FirestoreService>()
          .watchBookingsForTutor(uid)
          .listen(
            (List<Booking> bookings) {
              if (!mounted) return;
              final List<Booking> filtered = bookings
                  .where((Booking booking) => booking.studentId == _studentId)
                  .toList(growable: false)
                ..sort(
                  (Booking a, Booking b) =>
                      b.slotStart.compareTo(a.slotStart),
                );
              setState(() {
                _bookings = filtered;
                _loaded = true;
              });
            },
            onError: (Object error) {
              debugPrint('[STREAM] student_detail failed: $error');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _bookings = <Booking>[];
                  _loaded = true;
                });
              });
            },
          );
    } else {
      setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Student') return 'S';
    final List<String> parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();
  }

  Widget _statTile(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$value', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: _studentName,
      subtitle: _studentId.isEmpty
          ? 'Student profile'
          : 'ID: ${_studentId.substring(0, _studentId.length > 8 ? 8 : _studentId.length)}',
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? const Center(
              child: EmptyHint(message: 'No sessions with this student yet.'),
            )
          : ListView(
              children: <Widget>[
                SectionCard(
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(_getInitials(_studentName)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _studentName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Student',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final double tileWidth = (constraints.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              'Completed',
                              _bookings
                                  .where(
                                    (Booking booking) => booking.isCompleted,
                                  )
                                  .length,
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              'Upcoming',
                              _bookings
                                  .where((Booking booking) => booking.isUpcoming)
                                  .length,
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              'Cancelled by student',
                              _bookings
                                  .where(
                                    (Booking booking) =>
                                        booking.isCancelled &&
                                        booking.cancelledBy == 'student',
                                  )
                                  .length,
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: _statTile(
                              'Rescheduled',
                              _bookings
                                  .where(
                                    (Booking booking) => booking.isRescheduled,
                                  )
                                  .length,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text('Sessions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                for (final Booking booking in _bookings) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${DateFormat('EEE d MMM · h:mm a').format(booking.slotStart)} – ${DateFormat('h:mm a').format(booking.slotEnd)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  booking.subject,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (booking.isCancelled) ...<Widget>[
                                  const SizedBox(height: 3),
                                  Text(
                                    booking.cancellationSummary,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ] else if (booking.isRescheduled) ...<Widget>[
                                  const SizedBox(height: 3),
                                  Text(
                                    booking.rescheduleSummary,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.fromStatus(booking.status.value),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
