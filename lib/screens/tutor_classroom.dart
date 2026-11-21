import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/classroom_module.dart';
import '../models/exam.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/segmented_control.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorClassroomScreen extends StatefulWidget {
  const TutorClassroomScreen({super.key});

  @override
  State<TutorClassroomScreen> createState() => _TutorClassroomScreenState();
}

class _TutorClassroomScreenState extends State<TutorClassroomScreen> {
  String _tab = 'modules';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<ClassroomProvider>().watchTutorClassroom(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final List<ClassroomModule> modules =
        context.select<ClassroomProvider, List<ClassroomModule>>(
      (ClassroomProvider provider) => provider.modules,
    );
    final List<Assignment> assignments =
        context.select<ClassroomProvider, List<Assignment>>(
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
            values: const <String>['modules', 'assignments', 'exams'],
            value: _tab,
            onChanged: (String value) => setState(() => _tab = value),
            labelBuilder: (String value) => switch (value) {
              'modules' => 'Modules',
              'assignments' => 'Assignments',
              _ => 'Exams',
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: switch (_tab) {
              'modules' => modules.isEmpty
                  ? const EmptyHint(message: 'No modules yet.')
                  : ListView.builder(
                      itemCount: modules.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ClassroomModule module = modules[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SectionCard(
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.description_outlined),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(module.title),
                                      const SizedBox(height: 3),
                                      Text(
                                        module.description,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              'assignments' => assignments.isEmpty
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
                                  StatusBadge.fromStatus(assignment.status.value),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              _ => exams.isEmpty
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
    if (_tab == 'modules') {
      final Map<String, String>? values = await _showFields(
        context,
        const <String>['Title', 'Description'],
      );
      if (values == null) return;
      await classroom.createModule(
            tutorId: tutorId,
            title: values['Title'] ?? '',
            description: values['Description'] ?? '',
            fileUrl: '',
            fileType: '',
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
          title: Text(_tab == 'modules' ? 'New module' : 'New assignment'),
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
              onPressed: () => Navigator.of(dialogContext).pop(
                <String, String>{
                  for (int index = 0; index < labels.length; index++)
                    labels[index]: controllers[index].text.trim(),
                },
              ),
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
}
