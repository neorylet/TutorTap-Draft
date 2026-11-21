import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'screen_scaffold.dart';

class TutorAvailabilityScreen extends StatefulWidget {
  const TutorAvailabilityScreen({super.key});

  @override
  State<TutorAvailabilityScreen> createState() => _TutorAvailabilityScreenState();
}

class _TutorAvailabilityScreenState extends State<TutorAvailabilityScreen> {
  TutorProfile? _profile;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) _load(uid);
  }

  Future<void> _load(String uid) async {
    final TutorProfile? profile =
        await context.read<FirestoreService>().fetchTutor(uid);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final TutorProfile? profile = _profile;
    final List<TimeSlot> slots = profile?.slots ?? const <TimeSlot>[];

    return ScreenScaffold(
      title: 'Availability',
      subtitle: 'Add one-hour online session slots.',
      floatingActionButton: profile == null
          ? null
          : FloatingActionButton(
              onPressed: _addSlot,
              child: const Icon(Icons.add),
            ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : slots.isEmpty
              ? const EmptyHint(message: 'No slots yet. Add your first one.')
              : ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (BuildContext context, int index) {
                    final TimeSlot slot = slots[index];
                    final bool booked = slot.isBooked;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SectionCard(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              booked
                                  ? Icons.event_busy_outlined
                                  : Icons.schedule_outlined,
                              color: booked
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    DateFormat('EEE d MMM').format(slot.start),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${DateFormat('h:mm a').format(slot.start)} – ${DateFormat('h:mm a').format(slot.end)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (!booked)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeSlot(slot),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _addSlot() async {
    final TutorProfile? profile = _profile;
    if (profile == null) return;
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;
    final DateTime start = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final TimeSlot slot = TimeSlot(
      id: 'slot-${DateTime.now().microsecondsSinceEpoch}',
      start: start,
      end: start.add(const Duration(hours: 1)),
    );
    await _save(profile.copyWith(slots: <TimeSlot>[...profile.slots, slot]));
  }

  Future<void> _removeSlot(TimeSlot slot) async {
    final TutorProfile? profile = _profile;
    if (profile == null) return;
    await _save(
      profile.copyWith(
        slots: profile.slots
            .where((TimeSlot item) => item.id != slot.id)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _save(TutorProfile profile) async {
    final FirestoreService firestore = context.read<FirestoreService>();
    await firestore.saveTutorProfile(profile);
    if (!mounted) return;
    setState(() => _profile = profile);
  }
}
