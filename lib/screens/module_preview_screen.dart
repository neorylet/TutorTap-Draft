import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/classroom_module.dart';
import '../models/exam.dart';
import '../providers/classroom_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'exam_preview_screen.dart';
import 'screen_scaffold.dart';

class ModulePreviewScreen extends StatelessWidget {
  const ModulePreviewScreen({
    super.key,
    required this.module,
    required this.tutorId,
  });

  final ClassroomModule module;
  final String tutorId;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: module.title,
      showBack: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit module',
          onPressed: () => _showEditModuleDialog(context, module, tutorId),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) async {
            if (value == 'delete') {
              await _showDeleteModuleDialog(context, module, tutorId);
            } else if (value == 'attach_quiz') {
              await _showAttachQuizDialog(context, module.id, tutorId);
            } else if (value == 'detach_quiz') {
              await _detachQuiz(context, module.id, tutorId);
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'attach_quiz',
              child: Row(
                children: <Widget>[
                  Icon(Icons.quiz_outlined),
                  SizedBox(width: 8),
                  Text('Attach quiz'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'detach_quiz',
              child: Row(
                children: <Widget>[
                  Icon(Icons.quiz_outlined),
                  SizedBox(width: 8),
                  Text('Detach quiz'),
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
      body: Consumer<ClassroomProvider>(
        builder: (context, provider, child) {
          final Exam? attachedExam = provider.exams
              .where((e) => e.moduleId == module.id)
              .firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(module.description),
                    ],
                  ),
                ),
              ),
              if (module.fileUrl.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: const Text('Attached file'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openAttachment(module.fileUrl),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Quiz',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if (attachedExam != null) ...<Widget>[
                        Text(
                          '${attachedExam.title} · ${attachedExam.questions.length} questions',
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ExamPreviewScreen(
                                exam: attachedExam,
                                tutorId: tutorId,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.visibility),
                          label: const Text('View quiz'),
                        ),
                      ] else
                        const Text(
                          'No quiz attached',
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showEditModuleDialog(
    BuildContext context,
    ClassroomModule module,
    String tutorId,
  ) async {
    final TextEditingController titleController = TextEditingController(
      text: module.title,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: module.description,
    );

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Module'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final bool success = await provider.updateModule(
      module.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
      ),
    );

    if (!context.mounted) return;

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update module: ${provider.error}')),
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showDeleteModuleDialog(
    BuildContext context,
    ClassroomModule module,
    String tutorId,
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
        title: 'Delete Module',
        message: 'Delete "${module.title}"? This action cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final bool success = await classroomProvider.deleteModule(
      moduleId: module.id,
    );

    if (!context.mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete module: $error')),
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAttachQuizDialog(
    BuildContext context,
    String moduleId,
    String tutorId,
  ) async {
    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final List<Exam> availableExams = provider.exams
        .where((e) => e.moduleId == null)
        .toList();

    if (availableExams.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available quizzes to attach.')),
        );
      }
      return;
    }

    final String? selectedExamId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Quiz'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableExams.length,
            itemBuilder: (context, index) {
              final Exam exam = availableExams[index];
              return ListTile(
                title: Text(
                  '${exam.title} · ${exam.questions.length} questions',
                ),
                onTap: () => Navigator.of(dialogContext).pop(exam.id),
              );
            },
          ),
        ),
      ),
    );

    if (selectedExamId == null || !context.mounted) return;

    final bool success = await provider.attachExamToModule(
      examId: selectedExamId,
      moduleId: moduleId,
    );

    if (!context.mounted) return;

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach: ${provider.error}')),
        );
      }
    }
  }

  Future<void> _detachQuiz(
    BuildContext context,
    String moduleId,
    String tutorId,
  ) async {
    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final Exam? attachedExam = provider.exams
        .where((e) => e.moduleId == moduleId)
        .firstOrNull;

    if (attachedExam == null) return;

    final bool success = await provider.detachExam(examId: attachedExam.id);

    if (!context.mounted) return;

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to detach: ${provider.error}')),
        );
      }
    }
  }
}
