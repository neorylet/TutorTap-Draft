import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/assignment.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../services/cloudinary_service.dart';
import '../widgets/app_form_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _uploadedUrl;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Assignment? assignment =
        ModalRoute.of(context)?.settings.arguments as Assignment?;
    if (assignment == null) {
      return const ScreenScaffold(
        title: 'Assignment',
        body: EmptyHint(message: 'No assignment to show.'),
      );
    }
    final bool isUploading = context.select<ClassroomProvider, bool>(
      (ClassroomProvider provider) => provider.isUploading,
    );
    final PendingUpload? pending = context.select<ClassroomProvider, PendingUpload?>(
      (ClassroomProvider provider) => provider.pendingUpload,
    );
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: assignment.title,
      subtitle: 'Due ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                StatusBadge.fromStatus(assignment.status.value),
                const Spacer(),
                Text(
                  '${assignment.maxScore.toStringAsFixed(0)} pts',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Text(
                assignment.instructions,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (assignment.submissionText != null ||
                assignment.submissionUrl != null) ...<Widget>[
              const SizedBox(height: 12),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your submission',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    if (assignment.submissionText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(assignment.submissionText!),
                      ),
                    if (assignment.submissionUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          assignment.submissionUrl!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (assignment.status == AssignmentStatus.graded) ...<Widget>[
              const SizedBox(height: 12),
              SectionCard(
                child: Text(
                  'Grade: ${assignment.grade?.toStringAsFixed(1) ?? '—'} / ${assignment.maxScore.toStringAsFixed(0)}\n${assignment.feedback ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AppFormField(
              controller: _textController,
              label: 'Your answer',
              hint: 'Type your response here',
              maxLines: 6,
            ),
            const SizedBox(height: 10),
            PillButton(
              label: isUploading ? 'Uploading…' : 'Attach a file',
              variant: PillButtonVariant.secondary,
              onPressed: isUploading || user == null ? null : _pickAndUpload,
            ),
            if (_uploadedUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Attached: $_uploadedUrl',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            if (pending != null && pending.error != null) ...<Widget>[
              const SizedBox(height: 8),
              PillButton(
                label: 'Retry upload',
                variant: PillButtonVariant.amber,
                onPressed: isUploading ? null : _retry,
              ),
            ],
            const SizedBox(height: 16),
            PillButton(
              label: 'Submit assignment',
              onPressed: () => _submit(assignment),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final Assignment assignment =
        ModalRoute.of(context)!.settings.arguments as Assignment;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    final PlatformFile? file = await FilePicker.pickFile();
    final String? path = file?.path;
    if (path == null) return;
    final CloudinaryUploadResult? upload = await classroom.uploadFile(
          filePath: path,
          purpose: UploadPurpose.submission,
          ownerId: uid,
          assignmentId: assignment.id,
        );
    if (!mounted || upload == null) return;
    setState(() => _uploadedUrl = upload.secureUrl);
  }

  Future<void> _retry() async {
    final CloudinaryUploadResult? upload =
        await context.read<ClassroomProvider>().retryPendingUpload();
    if (!mounted || upload == null) return;
    setState(() => _uploadedUrl = upload.secureUrl);
  }

  Future<void> _submit(Assignment assignment) async {
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    await classroom.submitAssignment(
      assignment: assignment,
      submissionText: _textController.text.trim().isEmpty
          ? null
          : _textController.text.trim(),
      submissionUrl: _uploadedUrl,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
