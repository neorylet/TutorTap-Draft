import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/classroom_module.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/labeled_fields_dialog.dart';
import '../widgets/segmented_control.dart';
import '../widgets/status_badge.dart';
import 'create_assignment_screen.dart';
import 'create_exam_screen.dart';
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
      floatingActionButton: FloatingActionButton(
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
                          final String? attachmentUrl =
                              assignment.attachmentUrl;
                          final IconData attachmentIcon =
                              assignment.attachmentType == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.slideshow;
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(assignment.title),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Due ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (attachmentUrl != null)
                                      IconButton(
                                        icon: Icon(attachmentIcon),
                                        tooltip: 'Open attachment',
                                        onPressed: () =>
                                            _openAttachment(attachmentUrl),
                                      ),
                                    StatusBadge.fromStatus(
                                      assignment.status.value,
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (String value) async {
                                        if (value == 'edit') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  CreateAssignmentScreen(
                                                    tutorId: user?.uid ?? '',
                                                    existingAssignment:
                                                        assignment,
                                                  ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          await _showDeleteAssignmentDialog(
                                            context,
                                            assignment,
                                          );
                                        }
                                      },
                                      itemBuilder: (context) =>
                                          <PopupMenuEntry<String>>[
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
                        },
                      ),
              _ =>
                exams.isEmpty
                    ? const EmptyHint(message: 'No exams yet.')
                    : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Exam exam = exams[index];
                          final List<ClassroomModule> modules = context
                              .select<ClassroomProvider, List<ClassroomModule>>(
                                (ClassroomProvider p) => p.modules,
                              );
                          final ClassroomModule? attachedModule =
                              exam.moduleId != null
                              ? modules
                                    .where((m) => m.id == exam.moduleId)
                                    .firstOrNull
                              : null;

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
                                        child: Text(
                                          '${exam.title} · ${exam.questions.length} questions',
                                        ),
                                      ),
                                      if (exam.moduleId == null)
                                        TextButton(
                                          onPressed: () =>
                                              _showAttachExamDialog(
                                                context,
                                                exam.id,
                                              ),
                                          child: const Text('Attach'),
                                        ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (String value) async {
                                          if (value == 'edit') {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    CreateExamScreen(
                                                      tutorId: user?.uid ?? '',
                                                      existingExam: exam,
                                                      moduleId: exam.moduleId,
                                                    ),
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            await _showDeleteExamDialog(
                                              context,
                                              exam,
                                            );
                                          }
                                        },
                                        itemBuilder: (context) =>
                                            <PopupMenuEntry<String>>[
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
                                  if (attachedModule != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 36,
                                        top: 4,
                                      ),
                                      child: Text(
                                        'Attached to: ${attachedModule.title}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 36,
                                        top: 4,
                                      ),
                                      child: Text(
                                        'Not attached',
                                        style: TextStyle(color: Colors.grey),
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

  Future<void> _showAttachExamDialog(
    BuildContext context,
    String examId,
  ) async {
    final List<Course> courses = context
        .select<ClassroomProvider, List<Course>>(
          (ClassroomProvider p) => p.courses,
        );
    final List<ClassroomModule> modules = context
        .select<ClassroomProvider, List<ClassroomModule>>(
          (ClassroomProvider p) => p.modules,
        );

    if (courses.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No courses available to attach to.')),
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

    final List<ClassroomModule> courseModules = modules
        .where((m) => m.courseId == selectedCourseId)
        .toList();

    if (courseModules.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No modules in this course.')),
        );
      }
      return;
    }

    final String? selectedModuleId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Module'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: courseModules.length,
            itemBuilder: (context, index) {
              final ClassroomModule module = courseModules[index];
              return ListTile(
                title: Text(module.title),
                onTap: () => Navigator.of(dialogContext).pop(module.id),
              );
            },
          ),
        ),
      ),
    );

    if (selectedModuleId == null || !mounted) return;

    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final bool success = await provider.attachExamToModule(
      examId: examId,
      moduleId: selectedModuleId,
    );

    if (!mounted) return;

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach: ${provider.error}')),
        );
      }
    }
  }

  Future<void> _showDeleteExamDialog(BuildContext context, Exam exam) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    // ignore: use_build_context_synchronously
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

    if (confirmed != true) return;
    if (!mounted) return;

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
    // ignore: use_build_context_synchronously
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

    if (confirmed != true) return;
    if (!mounted) return;

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
