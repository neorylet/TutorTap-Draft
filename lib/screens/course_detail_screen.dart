import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/cloudinary_config.dart';
import '../models/classroom_module.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../services/cloudinary_service.dart';
import '../widgets/confirm_dialog.dart';
import 'create_exam_screen.dart';
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

    final List<ClassroomModule> courseModules = context
        .select<ClassroomProvider, List<ClassroomModule>>(
          (ClassroomProvider p) =>
              p.modules
                  .where((module) => module.courseId == widget.course.id)
                  .toList()
                ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        );

    final List<Exam> exams = context.select<ClassroomProvider, List<Exam>>(
      (ClassroomProvider p) => p.exams,
    );

    return ScreenScaffold(
      title: widget.course.title,
      subtitle: widget.course.description,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteCourseDialog(context, widget.course.id),
        ),
      ],
      body: courseModules.isEmpty
          ? const Center(child: Text('No modules yet.'))
          : ListView.builder(
              itemCount: courseModules.length,
              itemBuilder: (context, index) {
                final ClassroomModule module = courseModules[index];
                final bool hasFile = module.fileUrl.isNotEmpty;
                final IconData fileIcon = module.fileType == 'pdf'
                    ? Icons.picture_as_pdf
                    : Icons.slideshow;
                final Exam? attachedExam = exams
                    .where((exam) => exam.moduleId == module.id)
                    .firstOrNull;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: hasFile
                        ? () async {
                            final Uri uri = Uri.parse(module.fileUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          if (attachedExam != null)
                            const Icon(Icons.quiz)
                          else if (hasFile)
                            Icon(fileIcon)
                          else
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
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (String value) async {
                              if (value == 'delete') {
                                _showDeleteModuleDialog(context, module.id);
                              } else if (value == 'attach_quiz') {
                                await _showAttachQuizDialog(context, module.id);
                              } else if (value == 'detach_quiz' &&
                                  attachedExam != null) {
                                await _detachQuiz(context, attachedExam.id);
                              }
                            },
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              if (attachedExam == null)
                                const PopupMenuItem<String>(
                                  value: 'attach_quiz',
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.quiz_outlined),
                                      SizedBox(width: 8),
                                      Text('Attach quiz'),
                                    ],
                                  ),
                                )
                              else
                                PopupMenuItem<String>(
                                  value: 'detach_quiz',
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(Icons.quiz),
                                      const SizedBox(width: 8),
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
                      ),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _AddModuleDialog(
        tutorId: tutorId,
        courseId: courseId,
        orderIndex: nextOrderIndex,
      ),
    );
  }

  Future<void> _showDeleteCourseDialog(
    BuildContext context,
    String courseId,
  ) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    // ignore: use_build_context_synchronously
    final NavigatorState navigator = Navigator.of(context);
    // ignore: use_build_context_synchronously
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Delete Course',
        message: 'This will delete the course and all its modules. This action cannot be undone.',
        confirmLabel: 'Delete',
        requiredText: widget.course.title,
      ),
    );

    if (confirmed != true) return;

    navigator.pop();

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

  Future<void> _showDeleteModuleDialog(
    BuildContext context,
    String moduleId,
  ) async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    // ignore: use_build_context_synchronously
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(
      context,
    );

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const ConfirmDialog(
        title: 'Delete Module',
        message: 'This module will be deleted. This action cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final bool success = await classroomProvider.deleteModule(
      moduleId: moduleId,
    );

    if (!mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete module: $error')),
        );
      }
    }
  }

  Future<void> _showAttachQuizDialog(
    BuildContext context,
    String moduleId,
  ) async {
    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final List<Exam> unattachedExams = provider.exams
        .where((exam) => exam.moduleId == null)
        .toList();

    final String? choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Attach Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: const Text('Create new quiz'),
              leading: const Icon(Icons.add),
              onTap: () => Navigator.of(dialogContext).pop('create'),
            ),
            const Divider(),
            const Text('Or attach existing:'),
            const SizedBox(height: 8),
            if (unattachedExams.isEmpty)
              const Text('No unattached quizzes available.')
            else
              ...unattachedExams.map(
                (Exam exam) => ListTile(
                  title: Text(exam.title),
                  subtitle: Text('${exam.questions.length} questions'),
                  onTap: () => Navigator.of(dialogContext).pop(exam.id),
                ),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (choice == null) return;
    if (!mounted) return;

    if (choice == 'create') {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CreateExamScreen(
            tutorId: widget.course.tutorId,
            moduleId: moduleId,
          ),
        ),
      );
    } else {
      final bool success = await provider.attachExamToModule(
        examId: choice,
        moduleId: moduleId,
      );
      if (!mounted) return;

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to attach quiz: ${provider.error}')),
          );
        }
      }
    }
  }

  Future<void> _detachQuiz(BuildContext context, String examId) async {
    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final bool success = await provider.detachExam(examId: examId);
    if (!mounted) return;

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to detach quiz: ${provider.error}')),
        );
      }
    }
  }
}

class _AddModuleDialog extends StatefulWidget {
  const _AddModuleDialog({
    required this.tutorId,
    required this.courseId,
    required this.orderIndex,
  });

  final String tutorId;
  final String courseId;
  final int orderIndex;

  @override
  State<_AddModuleDialog> createState() => _AddModuleDialogState();
}

class _AddModuleDialogState extends State<_AddModuleDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _pickedFilePath;
  String? _pickedFileName;
  String? _fileSizeError;

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

  Future<void> _pickFile() async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: <String>['pdf', 'ppt', 'pptx'],
    );

    if (file == null || file.path == null) return;

    final String filePath = file.path!;
    final File fileObj = File(filePath);
    final int fileSize = await fileObj.length();

    if (fileSize > CloudinaryConfig.maxFileSizeBytes) {
      setState(() {
        _fileSizeError = 'File exceeds 20MB limit';
        _pickedFilePath = null;
        _pickedFileName = null;
      });
    } else {
      setState(() {
        _fileSizeError = null;
        _pickedFilePath = filePath;
        _pickedFileName = file.name;
      });
    }
  }

  void _clearFile() {
    setState(() {
      _pickedFilePath = null;
      _pickedFileName = null;
      _fileSizeError = null;
    });
  }

  Future<void> _handleAdd() async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _fileSizeError = 'Title is required';
      });
      return;
    }

    String fileUrl = '';
    String fileType = '';

    if (_pickedFilePath != null) {
      final String extension = _pickedFileName!.split('.').last.toLowerCase();
      fileType = extension;

      final CloudinaryUploadResult? uploadResult = await classroomProvider
          .uploadFile(
            filePath: _pickedFilePath!,
            purpose: UploadPurpose.module,
            ownerId: widget.tutorId,
            fileName: _pickedFileName,
          );

      if (!mounted) return;

      if (uploadResult == null) {
        setState(() {
          _fileSizeError = classroomProvider.error ?? 'Upload failed';
        });
        return;
      }

      fileUrl = uploadResult.secureUrl;
    }

    await classroomProvider.createModuleInCourse(
      tutorId: widget.tutorId,
      courseId: widget.courseId,
      title: title,
      description: description,
      fileUrl: fileUrl,
      fileType: fileType,
      orderIndex: widget.orderIndex,
    );

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _retryUpload() async {
    final ClassroomProvider classroomProvider = context
        .read<ClassroomProvider>();
    final CloudinaryUploadResult? result = await classroomProvider
        .retryPendingUpload();

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _fileSizeError = null;
      });
      await _handleAdd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUploading = context.select<ClassroomProvider, bool>(
      (ClassroomProvider p) => p.isUploading,
    );
    final PendingUpload? pendingUpload = context
        .select<ClassroomProvider, PendingUpload?>(
          (ClassroomProvider p) => p.pendingUpload,
        );

    final bool hasPendingError = pendingUpload?.error != null;

    return AlertDialog(
      title: const Text('Add Module'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          if (_pickedFileName != null) ...<Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.attach_file, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pickedFileName!,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _clearFile,
                ),
              ],
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach file'),
            ),
          if (_fileSizeError != null || hasPendingError) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              _fileSizeError ?? pendingUpload!.error!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
            if (hasPendingError)
              TextButton(onPressed: _retryUpload, child: const Text('Retry')),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (hasPendingError) {
              context.read<ClassroomProvider>().discardPendingUpload();
            }
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isUploading ? null : _handleAdd,
          child: isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
