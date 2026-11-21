import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<BookingProvider>().watchStudentBookings(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Booking> bookings = context.select<BookingProvider, List<Booking>>(
      (BookingProvider provider) => provider.bookings,
    );
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: 'My bookings',
      subtitle: user == null ? 'Sign in to see your sessions.' : 'All your sessions in one place.',
      showBack: false,
      body: bookings.isEmpty
          ? const EmptyHint(
              message: 'No bookings yet. Browse tutors to get started.',
              icon: Icons.calendar_month_outlined,
            )
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                final Booking booking = bookings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.bookingDetail,
                      arguments: booking,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_month_outlined, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  booking.tutorName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
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
                );
              },
            ),
    );
  }
}
