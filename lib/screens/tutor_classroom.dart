import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/booking.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/classroom_provider.dart';
import '../routing/app_routes.dart';
import '../services/firestore_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/labeled_fields_dialog.dart';
import '../widgets/segmented_control.dart';
import '../widgets/status_badge.dart';
import 'assignment_preview_screen.dart';
import 'create_assignment_screen.dart';
import 'create_exam_screen.dart';
import 'exam_preview_screen.dart';
import 'screen_scaffold.dart';

class TutorClassroomScreen extends StatefulWidget {
  const TutorClassroomScreen({super.key});

  @override
  State<TutorClassroomScreen> createState() => _TutorClassroomScreenState();
}

class _SessionEntry {
  const _SessionEntry({
    required this.time,
    required this.courseId,
    required this.courseTitle,
    required this.status,
    required this.isBooked,
    required this.studentName,
    required this.statusDetail,
    required this.booking,
  });

  final DateTime time;
  final String? courseId;
  final String courseTitle;
  final String status;
  final bool isBooked;
  final String? studentName;
  final String? statusDetail;
  final Booking? booking;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.entry, required this.onTap});

  final _SessionEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final List<String> statusParts = <String>[entry.status];
    if (entry.statusDetail != null && entry.statusDetail!.isNotEmpty) {
      statusParts.add(entry.statusDetail!);
    }
    if (entry.studentName != null && entry.studentName!.isNotEmpty) {
      statusParts.add(entry.studentName!);
    }

    final Widget card = SectionCard(
      child: Row(
        children: <Widget>[
          Icon(
            entry.isBooked
                ? Icons.event_busy_outlined
                : Icons.schedule_outlined,
            color: entry.isBooked
                ? Theme.of(context).colorScheme.primary
                : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateFormat('EEE d MMM, h:mm a').format(entry.time),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  entry.courseTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  statusParts.join(' · '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: entry.isBooked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (entry.booking != null) const Icon(Icons.chevron_right),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: onTap == null
          ? card
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: card,
            ),
    );
  }
}

class _ExamListTile extends StatelessWidget {
  const _ExamListTile({
    required this.exam,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Exam exam;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.quiz_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${exam.title} · ${exam.questions.length} questions',
                      ),
                      if (exam.dueDate != null)
                        Text(
                          'Due ${DateFormat('d MMM, h:mm a').format(exam.dueDate!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentListTile extends StatelessWidget {
  const _AssignmentListTile({
    required this.assignment,
    required this.onTap,
    required this.onOpenAttachment,
    required this.onEdit,
    required this.onDelete,
  });

  final Assignment assignment;
  final VoidCallback onTap;
  final VoidCallback onOpenAttachment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String? attachmentUrl = assignment.attachmentUrl;
    final IconData attachmentIcon = assignment.attachmentType == 'pdf'
        ? Icons.picture_as_pdf
        : Icons.slideshow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SectionCard(
          child: Row(
            children: <Widget>[
              const Icon(Icons.assignment_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(assignment.title),
                    const SizedBox(height: 3),
                    Text(
                      'Due ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (attachmentUrl != null)
                IconButton(
                  icon: Icon(attachmentIcon),
                  tooltip: 'Open attachment',
                  onPressed: onOpenAttachment,
                ),
              StatusBadge.fromStatus(assignment.status.value),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseListTile extends StatelessWidget {
  const _CourseListTile({
    required this.course,
    required this.onTap,
    required this.onDelete,
  });

  final Course course;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: SectionCard(
          child: Row(
            children: <Widget>[
              const Icon(Icons.book_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      course.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorClassroomScreenState extends State<TutorClassroomScreen> {
  String _tab = 'courses';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final String? uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid == null) return;
      context.read<ClassroomProvider>().watchTutorClassroom(uid);
      final BookingProvider bookings = context.read<BookingProvider>();
      bookings.watchTutorSlots(uid);
      bookings.watchTutorBookings(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final List<Course> courses = context
        .select<ClassroomProvider, List<Course>>(
          (ClassroomProvider provider) => provider.courses,
        );
    final List<Assignment> assignments = context
        .select<ClassroomProvider, List<Assignment>>(
          (ClassroomProvider provider) => provider.assignments,
        );
    final List<Exam> exams = context.select<ClassroomProvider, List<Exam>>(
      (ClassroomProvider provider) => provider.exams,
    );
    final List<TimeSlot> slots = context
        .select<BookingProvider, List<TimeSlot>>(
          (BookingProvider provider) => provider.slots,
        );
    final List<Booking> bookings = context
        .select<BookingProvider, List<Booking>>(
          (BookingProvider provider) => provider.bookings,
        );

    return ScreenScaffold(
      title: 'Classroom',
      subtitle: 'Materials, assignments and exams.',
      showBack: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tab == 'sessions') {
            if (user?.uid != null) {
              Navigator.of(context).pushNamed(AppRoutes.tutorAvailability);
            }
            return;
          }
          _add(user?.uid);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          SegmentedControl<String>(
            values: const <String>[
              'courses',
              'assignments',
              'exams',
              'sessions',
            ],
            value: _tab,
            onChanged: (String value) => setState(() => _tab = value),
            scrollable: true,
            labelBuilder: (String value) => switch (value) {
              'courses' => 'Courses',
              'assignments' => 'Assignments',
              'exams' => 'Exams',
              'sessions' => 'Sessions',
              _ => value,
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: switch (_tab) {
              'courses' =>
                courses.isEmpty
                    ? const EmptyHint(message: 'No courses yet.')
                    : ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Course course = courses[index];
                          return _CourseListTile(
                            course: course,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.courseDetail,
                              arguments: course,
                            ),
                            onDelete: () => _showDeleteCourseDialog(
                              context,
                              course.id,
                              course.title,
                            ),
                          );
                        },
                      ),
              'assignments' =>
                assignments.isEmpty
                    ? const EmptyHint(message: 'No assignments yet.')
                    : ListView.builder(
                        itemCount: assignments.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Assignment assignment = assignments[index];
                          return _AssignmentListTile(
                            assignment: assignment,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AssignmentPreviewScreen(
                                  assignment: assignment,
                                  tutorId: user?.uid ?? '',
                                ),
                              ),
                            ),
                            onOpenAttachment: () =>
                                _openAttachment(assignment.attachmentUrl!),
                            onEdit: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => CreateAssignmentScreen(
                                  tutorId: user?.uid ?? '',
                                  existingAssignment: assignment,
                                ),
                              ),
                            ),
                            onDelete: () => _showDeleteAssignmentDialog(
                              context,
                              assignment,
                            ),
                          );
                        },
                      ),
              'exams' =>
                exams.isEmpty
                    ? const EmptyHint(message: 'No exams yet.')
                    : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Exam exam = exams[index];
                          return _ExamListTile(
                            exam: exam,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ExamPreviewScreen(
                                  exam: exam,
                                  tutorId: user?.uid ?? '',
                                ),
                              ),
                            ),
                            onEdit: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => CreateExamScreen(
                                  tutorId: user?.uid ?? '',
                                  existingExam: exam,
                                  moduleId: exam.moduleId,
                                ),
                              ),
                            ),
                            onDelete: () =>
                                _showDeleteExamDialog(context, exam),
                          );
                        },
                      ),
              'sessions' => _buildSessionsTab(
                tutorId: user?.uid,
                courses: courses,
                slots: slots,
                bookings: bookings,
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab({
    required String? tutorId,
    required List<Course> courses,
    required List<TimeSlot> slots,
    required List<Booking> bookings,
  }) {
    if (tutorId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final Map<String, String> courseTitles = <String, String>{
      for (final Course course in courses) course.id: course.title,
    };
    String titleFor(String? courseId) {
      if (courseId == null) return 'No course';
      return courseTitles[courseId] ?? 'No course';
    }

    final DateTime now = DateTime.now();
    final List<Booking> tutorBookings = bookings
        .where((Booking booking) => booking.tutorId == tutorId)
        .toList(growable: false);
    final List<_SessionEntry> entries = <_SessionEntry>[];

    for (final TimeSlot slot in slots) {
      final Booking? matchedBooking = slot.isBooked
          ? tutorBookings
                .where(
                  (Booking booking) =>
                      booking.slotStart.isAtSameMomentAs(slot.start),
                )
                .cast<Booking?>()
                .firstOrNull
          : null;
      if (slot.isBooked && matchedBooking != null) continue;

      entries.add(
        _SessionEntry(
          time: slot.start,
          courseId: slot.courseId,
          courseTitle: titleFor(slot.courseId),
          status: slot.isBooked ? 'Booked' : 'Open',
          isBooked: slot.isBooked,
          studentName: null,
          statusDetail: null,
          booking: null,
        ),
      );
    }

    for (final Booking booking in tutorBookings) {
      entries.add(
        _SessionEntry(
          time: booking.slotStart,
          courseId: booking.courseId,
          courseTitle: titleFor(booking.courseId),
          status: 'Booked',
          isBooked: true,
          studentName: booking.studentName,
          statusDetail: booking.status.value,
          booking: booking,
        ),
      );
    }

    if (entries.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          EmptyHint(message: 'No sessions yet.'),
          Text(
            'Add availability to see your sessions here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    }

    entries.sort(
      (_SessionEntry a, _SessionEntry b) => a.time.compareTo(b.time),
    );
    final List<_SessionEntry> upcoming = entries
        .where((_SessionEntry entry) => !entry.time.isBefore(now))
        .toList(growable: false);
    final List<_SessionEntry> past = entries
        .where((_SessionEntry entry) => entry.time.isBefore(now))
        .toList(growable: false);

    Widget tileFor(_SessionEntry entry) {
      return _SessionTile(
        entry: entry,
        onTap: entry.booking == null
            ? null
            : () => Navigator.of(context)
                  .pushNamed(AppRoutes.bookingDetail, arguments: entry.booking),
      );
    }

    final Map<String?, List<_SessionEntry>> grouped =
        <String?, List<_SessionEntry>>{};
    for (final _SessionEntry entry in upcoming) {
      final String? courseId = entry.courseId;
      final String? key =
          courseId != null && !courseTitles.containsKey(courseId)
          ? null
          : courseId;
      grouped.putIfAbsent(key, () => <_SessionEntry>[]).add(entry);
    }

    final List<String?> groupKeys = grouped.keys.toList(growable: true)
      ..sort((String? a, String? b) {
        if (a == null) return 1;
        if (b == null) return -1;
        final int aIndex = courses.indexWhere((Course c) => c.id == a);
        final int bIndex = courses.indexWhere((Course c) => c.id == b);
        return (aIndex < 0 ? 1 << 30 : aIndex).compareTo(
          bIndex < 0 ? 1 << 30 : bIndex,
        );
      });

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        for (final String? key in groupKeys) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            child: Text(
              key == null ? 'No course' : courseTitles[key] ?? 'No course',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final _SessionEntry entry in grouped[key]!) tileFor(entry),
          const SizedBox(height: 12),
        ],
        if (past.isNotEmpty)
          ExpansionTile(
            title: Text('Past (${past.length})'),
            initiallyExpanded: false,
            children: <Widget>[
              for (final _SessionEntry entry in past) tileFor(entry),
            ],
          ),
      ],
    );
  }

  Future<void> _add(String? tutorId) async {
    if (tutorId == null) return;

    if (_tab == 'assignments') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CreateAssignmentScreen(tutorId: tutorId),
        ),
      );
      return;
    }

    if (_tab == 'exams') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CreateExamScreen(tutorId: tutorId),
        ),
      );
      return;
    }

    final Map<String, String>? values = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const LabeledFieldsDialog(
        title: 'New course',
        labels: <String>['Title', 'Description', 'Subject'],
      ),
    );
    if (values == null || !mounted) return;
    await context.read<ClassroomProvider>().createCourse(
      tutorId: tutorId,
      title: values['Title'] ?? '',
      description: values['Description'] ?? '',
      subject: values['Subject'] ?? '',
    );
  }

  Future<void> _showDeleteExamDialog(BuildContext context, Exam exam) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );

    final String message = exam.moduleId != null
        ? 'Delete "${exam.title}"? This will also detach it from its module. This action cannot be undone.'
        : 'Delete "${exam.title}"? This action cannot be undone.';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Delete Quiz',
        message: message,
        confirmLabel: 'Delete',
        requiredText: exam.title,
      ),
    );

    if (confirmed != true || !mounted) return;

    final bool success = await classroomProvider.deleteExam(examId: exam.id);

    if (!mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete quiz: $error')),
        );
      }
    }
  }

  Future<void> _showDeleteAssignmentDialog(
    BuildContext context,
    Assignment assignment,
  ) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Delete Assignment',
        message: 'Delete "${assignment.title}"? This action cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );

    if (confirmed != true || !mounted) return;

    final bool success = await classroomProvider.deleteAssignment(
      assignmentId: assignment.id,
    );

    if (!mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete assignment: $error')),
        );
      }
    }
  }

  Future<void> _openAttachment(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showDeleteCourseDialog(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    final FirestoreService firestoreService = context.read<FirestoreService>();
    final String? tutorId = context.read<AuthProvider>().currentUser?.uid;
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Delete Course',
        message: 'Delete "$courseTitle"? This action cannot be undone.',
        confirmLabel: 'Delete',
        requiredText: courseTitle,
      ),
    );

    if (confirmed != true || !mounted) return;

    if (tutorId != null) {
      final TutorProfile? profile = await firestoreService.fetchTutor(tutorId);
      if (profile != null && profile.slots.any((s) => s.courseId == courseId)) {
        final List<TimeSlot> updatedSlots = profile.slots
            .map(
              (TimeSlot slot) => slot.courseId == courseId
                  ? slot.copyWith(courseId: null)
                  : slot,
            )
            .toList(growable: false);
        await firestoreService.saveTutorProfile(
          profile.copyWith(slots: updatedSlots),
        );
      }
    }

    if (!mounted) return;

    final bool success = await classroomProvider.deleteCourse(
      courseId: courseId,
    );

    if (!mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete course: $error')),
        );
      }
    }
  }
}
