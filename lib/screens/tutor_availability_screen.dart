import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../services/firestore_service.dart';
import 'screen_scaffold.dart';

class TutorAvailabilityScreen extends StatefulWidget {
  const TutorAvailabilityScreen({super.key});

  @override
  State<TutorAvailabilityScreen> createState() =>
      _TutorAvailabilityScreenState();
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
    final TutorProfile? profile = await context
        .read<FirestoreService>()
        .fetchTutor(uid);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final TutorProfile? profile = _profile;
    final List<TimeSlot> slots = profile?.slots ?? const <TimeSlot>[];
    final List<Course> courses = context.watch<ClassroomProvider>().courses;

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
                final Course? course = slot.courseId != null
                    ? courses.where((c) => c.id == slot.courseId).firstOrNull
                    : null;
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
                              if (course != null)
                                Text(
                                  course.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                )
                              else if (slot.courseId == null)
                                Text(
                                  'No course',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
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

    final List<Course> courses = context.read<ClassroomProvider>().courses;

    if (courses.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No courses available. Create a course first.'),
          ),
        );
      }
      return;
    }

    final String? selectedCourseId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Course'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final Course course = courses[index];
              return ListTile(
                title: Text(course.title),
                onTap: () => Navigator.of(dialogContext).pop(course.id),
              );
            },
          ),
        ),
      ),
    );

    if (selectedCourseId == null || !mounted) return;

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
    final DateTime end = start.add(const Duration(hours: 1));

    // Validate: reject past slots
    if (start.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot add slots in the past.')),
        );
      }
      return;
    }

    // Validate: reject overlapping slots
    final bool overlaps = profile.slots.any((TimeSlot s) {
      return start.isBefore(s.end) && end.isAfter(s.start);
    });
    if (overlaps) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This slot overlaps with an existing slot.'),
          ),
        );
      }
      return;
    }

    final TimeSlot slot = TimeSlot(
      id: 'slot-${DateTime.now().microsecondsSinceEpoch}',
      start: start,
      end: end,
      courseId: selectedCourseId,
    );
    await _save(profile.copyWith(slots: <TimeSlot>[...profile.slots, slot]));
  }

  Future<void> _removeSlot(TimeSlot slot) async {
    final TutorProfile? profile = _profile;
    if (profile == null) return;

    // Prevent deleting slots with bookings
    if (slot.isBooked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete a slot that has been booked.'),
          ),
        );
      }
      return;
    }

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
