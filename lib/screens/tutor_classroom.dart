import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/segmented_control.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorClassroomScreen extends StatefulWidget {
  const TutorClassroomScreen({super.key});

  @override
  State<TutorClassroomScreen> createState() => _TutorClassroomScreenState();
}

class _TutorClassroomScreenState extends State<TutorClassroomScreen> {
  String _tab = 'courses';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // FIX: Use addPostFrameCallback to prevent modifying provider state during the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final String? uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<ClassroomProvider>().watchTutorClassroom(uid);
      }
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

    return ScreenScaffold(
      title: 'Classroom',
      subtitle: 'Materials, assignments and exams.',
      showBack: false,
      floatingActionButton: _tab == 'exams'
          ? null
          : FloatingActionButton(
              onPressed: () => _add(user?.uid),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: <Widget>[
          SegmentedControl<String>(
            values: const <String>['courses', 'assignments', 'exams'],
            value: _tab,
            onChanged: (String value) => setState(() => _tab = value),
            labelBuilder: (String value) => switch (value) {
              'courses' => 'Courses',
              'assignments' => 'Assignments',
              _ => 'Exams',
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.courseDetail,
                                arguments: course,
                              ),
                              onLongPress: () => _showDeleteCourseDialog(
                                context,
                                course.id,
                                course.title,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: SectionCard(
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.book_outlined),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            course.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            course.description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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
                        },
                      ),
              'assignments' =>
                assignments.isEmpty
                    ? const EmptyHint(message: 'No assignments yet.')
                    : ListView.builder(
                        itemCount: assignments.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Assignment assignment = assignments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.grading,
                                arguments: assignment,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: SectionCard(
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.assignment_outlined),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(assignment.title)),
                                    StatusBadge.fromStatus(
                                      assignment.status.value,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              _ =>
                exams.isEmpty
                    ? const EmptyHint(message: 'No exams yet.')
                    : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Exam exam = exams[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SectionCard(
                              child: Row(
                                children: <Widget>[
                                  const Icon(Icons.quiz_outlined),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${exam.title} · ${exam.questions.length} questions',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _add(String? tutorId) async {
    if (tutorId == null) return;
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    if (_tab == 'courses') {
      final Map<String, String>? values = await _showFields(
        context,
        const <String>['Title', 'Description', 'Subject'],
      );
      if (values == null) return;
      await classroom.createCourse(
        tutorId: tutorId,
        title: values['Title'] ?? '',
        description: values['Description'] ?? '',
        subject: values['Subject'] ?? '',
      );
      return;
    }
    final Map<String, String>? values = await _showFields(
      context,
      const <String>['Title', 'Instructions'],
    );
    if (values == null) return;
    await classroom.createAssignment(
      tutorId: tutorId,
      studentId: 'all-students',
      title: values['Title'] ?? '',
      instructions: values['Instructions'] ?? '',
      dueDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<Map<String, String>?> _showFields(
    BuildContext context,
    List<String> labels,
  ) async {
    final List<TextEditingController> controllers = labels
        .map((String label) => TextEditingController())
        .toList(growable: false);
    final Map<String, String>? result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(_tab == 'courses' ? 'New course' : 'New assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int index = 0; index < labels.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(labelText: labels[index]),
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(<String, String>{
                for (int index = 0; index < labels.length; index++)
                  labels[index]: controllers[index].text.trim(),
              }),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    for (final TextEditingController controller in controllers) {
      controller.dispose();
    }
    return result;
  }

  Future<void> _showDeleteCourseDialog(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    // ignore: use_build_context_synchronously
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

    if (confirmed != true) return;
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
