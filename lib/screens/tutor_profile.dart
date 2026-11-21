import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../services/firestore_service.dart';
import '../widgets/pill_button.dart';
import '../widgets/slot_cell.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  TutorProfile? _tutor;
  bool _loading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is TutorProfile) {
      setState(() {
        _tutor = arguments;
        _loading = false;
      });
      context.read<BookingProvider>().selectTutor(arguments);
      context.read<BookingProvider>().watchTutorSlots(arguments.uid);
    } else if (arguments is String) {
      _load(arguments);
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _load(String uid) async {
    try {
      final TutorProfile? tutor =
          await context.read<FirestoreService>().fetchTutor(uid);
      if (!mounted) return;
      if (tutor != null) {
        context.read<BookingProvider>()
          ..selectTutor(tutor)
          ..watchTutorSlots(uid);
      }
      setState(() {
        _tutor = tutor;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final TutorProfile? tutor = _tutor;
    if (tutor == null) {
      return const ScreenScaffold(
        title: 'Tutor not found',
        body: EmptyHint(message: 'This tutor profile is unavailable.'),
      );
    }

    final List<TimeSlot> slots = context.select<BookingProvider, List<TimeSlot>>(
      (BookingProvider provider) => provider.slots,
    );
    final String? selectedSlotId =
        context.select<BookingProvider, String?>((BookingProvider provider) {
      return provider.selectedSlot?.id;
    });
    final String? error = context.select<BookingProvider, String?>(
      (BookingProvider provider) => provider.error,
    );
    final DateTime now = DateTime.now();
    final String? uid = context.select<AuthProvider, AppUser?>((AuthProvider p) {
          return p.currentUser;
        })?.uid;

    return ScreenScaffold(
      title: tutor.displayName,
      subtitle: tutor.subjects.join(' · '),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(tutor.initials),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '★ ${tutor.rating.toStringAsFixed(1)} (${tutor.ratingCount})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${tutor.hourlyRate.toStringAsFixed(0)}/hour',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Spacer(),
                const StatusBadge(label: 'Verified', tone: StatusTone.positive),
              ],
            ),
            const SizedBox(height: 16),
            Text(tutor.bio, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
              'Online room: ${tutor.meetingRoomInfo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text('Choose a slot', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (slots.isEmpty)
              const EmptyHint(message: 'No open slots right now.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots.map((TimeSlot slot) {
                  final SlotCellState state;
                  if (slot.isBooked) {
                    state = SlotCellState.taken;
                  } else if (uid != null && slot.isLockedBy(uid, now)) {
                    state = SlotCellState.selected;
                  } else if (slot.isLocked(now)) {
                    state = SlotCellState.locked;
                  } else if (slot.id == selectedSlotId) {
                    state = SlotCellState.selected;
                  } else {
                    state = SlotCellState.available;
                  }
                  final String label =
                      DateFormat('EEE d MMM\nh:mm a').format(slot.start);
                  return SizedBox(
                    width: 112,
                    child: SlotCell(
                      label: label,
                      state: state,
                      holdLabel: uid != null && slot.isLockedBy(uid, now)
                          ? 'Held for you'
                          : null,
                      onTap: () => _selectSlot(slot),
                    ),
                  );
                }).toList(growable: false),
              ),
            if (error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 20),
            PillButton(
              label: 'Continue to checkout',
              onPressed: selectedSlotId == null ? null : _goToCheckout,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectSlot(TimeSlot slot) async {
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    final BookingProvider booking = context.read<BookingProvider>();
    booking.selectSlot(slot);
    final bool locked = await booking.lockSelectedSlot(studentUid: uid);
    if (locked && mounted) {
      Navigator.of(context).pushNamed(AppRoutes.checkout);
    }
  }

  Future<void> _goToCheckout() async {
    Navigator.of(context).pushNamed(AppRoutes.checkout);
  }
}
