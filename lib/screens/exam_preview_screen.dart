import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/classroom_module.dart';
import '../models/exam.dart';
import '../providers/classroom_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'create_exam_screen.dart';
import 'screen_scaffold.dart';

class ExamPreviewScreen extends StatelessWidget {
  const ExamPreviewScreen({
    super.key,
    required this.exam,
    required this.tutorId,
  });

  final Exam exam;
  final String tutorId;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: exam.title,
      showBack: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit quiz',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreateExamScreen(
                tutorId: tutorId,
                existingExam: exam,
                moduleId: exam.moduleId,
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) async {
            if (value == 'delete') {
              await _showDeleteExamDialog(context, exam, tutorId);
            } else if (value == 'attach') {
              await _showAttachExamDialog(context, exam.id, tutorId);
            } else if (value == 'detach') {
              await _detachExam(context, exam.id, tutorId);
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            if (exam.moduleId == null)
              const PopupMenuItem<String>(
                value: 'attach',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.link),
                        SizedBox(width: 8),
                        Text('Attach to module'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Shows this quiz at the end of the module.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              const PopupMenuItem<String>(
                value: 'detach',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.link_off),
                    SizedBox(width: 8),
                    Text('Detach from module'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (exam.dueDate != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.event_outlined),
                    const SizedBox(width: 12),
                    Text(
                      'Due ${DateFormat('d MMM, h:mm a').format(exam.dueDate!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          if (exam.dueDate != null) const SizedBox(height: 16),
          ...List.generate(exam.questions.length, (int index) {
            final question = exam.questions[index];
            return Card(
              margin: EdgeInsets.only(
                bottom: index < exam.questions.length - 1 ? 16 : 0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Question ${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(question.prompt),
                    const SizedBox(height: 12),
                    ...List.generate(question.choices.length, (int i) {
                      final bool isCorrect = question.answerIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isCorrect ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.choices[i],
                                style: TextStyle(
                                  fontWeight: isCorrect
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isCorrect)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Correct answer',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showDeleteExamDialog(
    BuildContext context,
    Exam exam,
    String tutorId,
  ) async {
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
    if (!context.mounted) return;

    final bool success = await classroomProvider.deleteExam(examId: exam.id);

    if (!context.mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete quiz: $error')),
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAttachExamDialog(
    BuildContext context,
    String examId,
    String tutorId,
  ) async {
    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final List<ClassroomModule> courseModules = provider.modules;

    if (courseModules.isEmpty) {
      if (context.mounted) {
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

    if (selectedModuleId == null || !context.mounted) return;

    final bool success = await provider.attachExamToModule(
      examId: examId,
      moduleId: selectedModuleId,
    );

    if (!context.mounted) return;

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach: ${provider.error}')),
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _detachExam(
    BuildContext context,
    String examId,
    String tutorId,
  ) async {
    final ClassroomProvider provider = context.read<ClassroomProvider>();

    final bool success = await provider.detachExam(examId: examId);

    if (!context.mounted) return;

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to detach: ${provider.error}')),
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
