import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/cloudinary_config.dart';
import '../models/assignment.dart';
import '../providers/classroom_provider.dart';
import '../services/cloudinary_service.dart';
import '../widgets/app_form_field.dart';
import '../widgets/due_date_tile.dart';
import 'screen_scaffold.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({
    super.key,
    required this.tutorId,
    this.existingAssignment,
  });

  final String tutorId;
  final Assignment? existingAssignment;

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _pickedFilePath;
  String? _pickedFileName;
  String? _errorMessage;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingAssignment != null) {
      _titleController.text = widget.existingAssignment!.title;
      _instructionsController.text = widget.existingAssignment!.instructions;
      _dueDate = widget.existingAssignment!.dueDate;
      if (widget.existingAssignment!.attachmentUrl != null) {
        _pickedFilePath = null;
        _pickedFileName = widget.existingAssignment!.attachmentType != null
            ? 'existing.${widget.existingAssignment!.attachmentType}'
            : 'existing file';
      }
    }
  }

  Future<void> _pickFile() async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: <String>['pdf', 'ppt', 'pptx'],
    );
    if (file == null || file.path == null || !mounted) return;

    final String filePath = file.path!;
    final int fileSize = await File(filePath).length();
    if (!mounted) return;

    if (fileSize > CloudinaryConfig.maxFileSizeBytes) {
      setState(() {
        _errorMessage = 'File exceeds 20MB limit';
        _pickedFilePath = null;
        _pickedFileName = null;
      });
      return;
    }

    context.read<ClassroomProvider>().discardPendingUpload();
    setState(() {
      _errorMessage = null;
      _pickedFilePath = filePath;
      _pickedFileName = file.name;
    });
  }

  void _clearFile() {
    context.read<ClassroomProvider>().discardPendingUpload();
    setState(() {
      _pickedFilePath = null;
      _pickedFileName = null;
      _errorMessage = null;
    });
  }

  Future<void> _handleCreate() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Title is required');
      return;
    }

    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    setState(() => _errorMessage = null);

    String? attachmentUrl;
    String? attachmentType;

    if (_pickedFilePath != null) {
      final String? fileName = _pickedFileName;
      attachmentType = fileName?.split('.').last.toLowerCase();

      final CloudinaryUploadResult? uploadResult = await classroom.uploadFile(
        filePath: _pickedFilePath!,
        purpose: UploadPurpose.assignmentAttachment,
        ownerId: widget.tutorId,
        fileName: fileName,
      );
      if (!mounted) return;

      if (uploadResult == null) {
        setState(() => _errorMessage = classroom.error ?? 'Upload failed');
        return;
      }
      attachmentUrl = uploadResult.secureUrl;
    }

    await (widget.existingAssignment != null
        ? _updateAssignment
        : _saveAssignment)(
      classroom: classroom,
      title: title,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );
  }

  Future<void> _saveAssignment({
    required ClassroomProvider classroom,
    required String title,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    setState(() => _isCreating = true);
    try {
      await classroom.createAssignment(
        tutorId: widget.tutorId,
        studentId: 'all-students',
        title: title,
        instructions: _instructionsController.text.trim(),
        dueDate: _dueDate,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
        _errorMessage = 'Failed to create assignment: $error';
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _updateAssignment({
    required ClassroomProvider classroom,
    required String title,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    setState(() => _isCreating = true);
    try {
      final Assignment updated = widget.existingAssignment!.copyWith(
        title: title,
        instructions: _instructionsController.text.trim(),
        dueDate: _dueDate,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
      await classroom.updateAssignment(updated);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
        _errorMessage = 'Failed to update assignment: $error';
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _retryUpload() async {
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    final CloudinaryUploadResult? result = await classroom.retryPendingUpload();
    if (!mounted) return;
    if (result == null) {
      setState(() => _errorMessage = null);
      return;
    }

    setState(() => _errorMessage = null);
    await (widget.existingAssignment != null
        ? _updateAssignment
        : _saveAssignment)(
      classroom: classroom,
      title: _titleController.text.trim(),
      attachmentUrl: result.secureUrl,
      attachmentType: _pickedFileName?.split('.').last.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUploading = context.select<ClassroomProvider, bool>(
      (ClassroomProvider provider) => provider.isUploading,
    );
    final PendingUpload? pendingUpload = context
        .select<ClassroomProvider, PendingUpload?>(
          (ClassroomProvider provider) => provider.pendingUpload,
        );
    final bool hasPendingError = pendingUpload?.error != null;
    final bool isBusy = isUploading || _isCreating;
    final String? displayedError = _errorMessage ?? pendingUpload?.error;

    return ScreenScaffold(
      title: widget.existingAssignment != null
          ? 'Edit assignment'
          : 'New assignment',
      subtitle: widget.existingAssignment != null
          ? 'Edit this task for all students.'
          : 'Create a task for all students.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppFormField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Chapter 5 practice problems',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  AppFormField(
                    controller: _instructionsController,
                    label: 'Instructions',
                    hint: 'Explain what students need to do',
                    maxLines: 6,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  DueDateTile(
                    dueDate: _dueDate,
                    onChanged: (DateTime? value) {
                      if (value != null) {
                        setState(() => _dueDate = value);
                      }
                    },
                    isRequired: true,
                    isBusy: isBusy,
                  ),
                  const SizedBox(height: 14),
                  if (_pickedFileName != null) ...<Widget>[
                    SectionCard(
                      child: Row(
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
                            tooltip: 'Remove attachment',
                            onPressed: isBusy ? null : _clearFile,
                          ),
                        ],
                      ),
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach file (PDF/PPT)'),
                    ),
                  if (displayedError != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      displayedError,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    if (hasPendingError)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: isBusy ? null : _retryUpload,
                          child: const Text('Retry'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isBusy || _titleController.text.trim().isEmpty
                ? null
                : _handleCreate,
            child: isBusy
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    widget.existingAssignment != null
                        ? 'Update assignment'
                        : 'Create assignment',
                  ),
          ),
        ],
      ),
    );
  }
}
