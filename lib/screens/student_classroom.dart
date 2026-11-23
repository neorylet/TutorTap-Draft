import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user.dart';
import '../models/assignment.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class StudentClassroomScreen extends StatefulWidget {
  const StudentClassroomScreen({super.key});

  @override
  State<StudentClassroomScreen> createState() => _StudentClassroomScreenState();
}

class _StudentClassroomScreenState extends State<StudentClassroomScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<ClassroomProvider>().watchStudentAssignments(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Assignment> assignments =
        context.select<ClassroomProvider, List<Assignment>>(
      (ClassroomProvider provider) => provider.assignments,
    );
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: 'Classroom',
      subtitle: user == null ? 'Sign in to see your work.' : 'Assignments from your tutors.',
      showBack: false,
      body: assignments.isEmpty
          ? const EmptyHint(
              message: 'No assignments yet.',
              icon: Icons.assignment_outlined,
            )
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (BuildContext context, int index) {
                final Assignment assignment = assignments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.assignment,
                      arguments: assignment,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.description_outlined, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  assignment.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due ${DateFormat('d MMM, h:mm a').format(assignment.dueDate)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (assignment.attachmentUrl != null)
                            IconButton(
                              icon: Icon(
                                assignment.attachmentType == 'pdf'
                                    ? Icons.picture_as_pdf
                                    : Icons.slideshow,
                              ),
                              tooltip: 'Open attachment',
                              onPressed: () =>
                                  _openAttachment(assignment.attachmentUrl!),
                            ),
                          StatusBadge.fromStatus(assignment.status.value),
                        ],
                      ),
                    ),
                  ),
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
}
