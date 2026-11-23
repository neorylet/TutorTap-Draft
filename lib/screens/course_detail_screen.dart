import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/classroom_module.dart';
import '../models/course.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import 'screen_scaffold.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final String? tutorId = context.select<AuthProvider, String?>(
      (AuthProvider p) => p.currentUser?.uid,
    );
    if (tutorId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view this course.')),
      );
    }

    final List<ClassroomModule> allModules = context
        .select<ClassroomProvider, List<ClassroomModule>>(
          (ClassroomProvider p) => p.modules,
        );
    final List<ClassroomModule> courseModules =
        allModules
            .where((module) => module.courseId == widget.course.id)
            .toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return ScreenScaffold(
      title: widget.course.title,
      subtitle: widget.course.description,
      body: courseModules.isEmpty
          ? const Center(child: Text('No modules yet.'))
          : ListView.builder(
              itemCount: courseModules.length,
              itemBuilder: (context, index) {
                final ClassroomModule module = courseModules[index];
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
                        Chip(
                          label: Text('Module ${index + 1}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModuleDialog(
          context,
          tutorId,
          widget.course.id,
          courseModules.length,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddModuleDialog(
    BuildContext context,
    String tutorId,
    String courseId,
    int nextOrderIndex,
  ) async {
    final Map<String, String>? result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => const _AddModuleDialog(),
    );

    if (result == null) return;
    if (!mounted) return;

    await context.read<ClassroomProvider>().createModuleInCourse(
      tutorId: tutorId,
      courseId: courseId,
      title: result['title'] ?? '',
      description: result['description'] ?? '',
      orderIndex: nextOrderIndex,
    );
  }
}

class _AddModuleDialog extends StatefulWidget {
  const _AddModuleDialog();

  @override
  State<_AddModuleDialog> createState() => _AddModuleDialogState();
}

class _AddModuleDialogState extends State<_AddModuleDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Module'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(<String, String>{
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
          }),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
