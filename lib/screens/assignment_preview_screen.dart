import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/assignment.dart';
import '../providers/classroom_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/confirm_dialog.dart';
import 'create_assignment_screen.dart';
import 'screen_scaffold.dart';

class AssignmentPreviewScreen extends StatelessWidget {
  const AssignmentPreviewScreen({
    super.key,
    required this.assignment,
    required this.tutorId,
  });

  final Assignment assignment;
  final String tutorId;

  @override
  Widget build(BuildContext context) {
    final String? attachmentUrl = assignment.attachmentUrl;
    final IconData attachmentIcon = assignment.attachmentType == 'pdf'
        ? Icons.picture_as_pdf
        : Icons.slideshow;

    return ScreenScaffold(
      title: assignment.title,
      showBack: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit assignment',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreateAssignmentScreen(
                tutorId: tutorId,
                existingAssignment: assignment,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.grading),
          tooltip: 'View submissions / Grade',
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.grading,
            arguments: assignment,
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) async {
            if (value == 'delete') {
              await _showDeleteAssignmentDialog(context, assignment);
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(assignment.instructions),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Due date'),
              subtitle: Text(
                DateFormat('d MMM, yyyy, h:mm a').format(assignment.dueDate),
              ),
            ),
          ),
          if (attachmentUrl != null) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(attachmentIcon),
                title: const Text('Attached file'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openAttachment(attachmentUrl),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.grading),
              title: const Text('View submissions / Grade'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.grading,
                arguments: assignment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showDeleteAssignmentDialog(
    BuildContext context,
    Assignment assignment,
  ) async {
    final ClassroomProvider classroomProvider = context.read<ClassroomProvider>();
    // ignore: use_build_context_synchronously
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Delete Assignment',
        message: 'Delete "${assignment.title}"? This action cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final bool success = await classroomProvider.deleteAssignment(
      assignmentId: assignment.id,
    );

    if (!context.mounted) return;

    if (!success) {
      final String? error = classroomProvider.error;
      if (error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete assignment: $error')),
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
