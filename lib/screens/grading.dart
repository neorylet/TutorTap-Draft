import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/assignment.dart';
import '../providers/classroom_provider.dart';
import '../widgets/app_form_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class GradingScreen extends StatefulWidget {
  const GradingScreen({super.key});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final Assignment? assignment =
        ModalRoute.of(context)?.settings.arguments as Assignment?;
    if (assignment != null) {
      _gradeController.text =
          (assignment.grade ?? assignment.maxScore).toStringAsFixed(0);
      _feedbackController.text = assignment.feedback ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Assignment? assignment =
        ModalRoute.of(context)?.settings.arguments as Assignment?;
    if (assignment == null) {
      return const ScreenScaffold(
        title: 'Grading',
        body: EmptyHint(message: 'No assignment to grade.'),
      );
    }

    return ScreenScaffold(
      title: 'Grade submission',
      subtitle: assignment.title,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                StatusBadge.fromStatus(assignment.status.value),
                const Spacer(),
                if (assignment.attachmentUrl != null)
                  IconButton(
                    icon: Icon(
                      assignment.attachmentType == 'pdf'
                          ? Icons.picture_as_pdf
                          : Icons.slideshow,
                    ),
                    tooltip: 'Open attachment',
                    onPressed: () => _openAttachment(assignment.attachmentUrl!),
                  ),
                Text(
                  'Max ${assignment.maxScore.toStringAsFixed(0)} pts',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Due ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Student answer',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    assignment.submissionText ?? 'No written answer.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (assignment.submissionUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        assignment.submissionUrl!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppFormField(
              controller: _gradeController,
              label: 'Grade',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.score_outlined,
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _feedbackController,
              label: 'Feedback',
              hint: 'What went well? What should improve?',
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            PillButton(
              label: 'Save grade',
              onPressed: () => _save(assignment),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _save(Assignment assignment) async {
    final double grade = double.tryParse(_gradeController.text) ?? 0;
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    await classroom.gradeAssignment(
      assignmentId: assignment.id,
      grade: grade,
      feedback: _feedbackController.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
