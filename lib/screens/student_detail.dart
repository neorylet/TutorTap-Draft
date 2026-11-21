import 'package:flutter/material.dart';

import 'screen_scaffold.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final String studentId = arguments is Map<String, dynamic>
        ? arguments['studentId'] as String? ?? ''
        : '';
    final String studentName = arguments is Map<String, dynamic>
        ? arguments['studentName'] as String? ?? 'Student'
        : 'Student';

    return ScreenScaffold(
      title: studentName,
      subtitle: studentId.isEmpty ? 'Student profile' : 'ID: ${studentId.substring(0, studentId.length > 8 ? 8 : studentId.length)}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Session history and assignment progress will appear here as the classroom flows are built out.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
