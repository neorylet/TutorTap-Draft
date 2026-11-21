import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../routing/app_routes.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class ExamIntroScreen extends StatelessWidget {
  const ExamIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Exam? exam = ModalRoute.of(context)?.settings.arguments as Exam?;
    if (exam == null) {
      return const ScreenScaffold(
        title: 'Exam',
        body: EmptyHint(message: 'No exam to show.'),
      );
    }

    return ScreenScaffold(
      title: exam.title,
      subtitle: 'Set by your tutor.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionCard(
            child: Column(
              children: <Widget>[
                _Fact(icon: Icons.help_outline, label: '${exam.questions.length} questions'),
                const SizedBox(height: 12),
                _Fact(icon: Icons.timer_outlined, label: '${exam.timeLimitMin} minutes'),
                const SizedBox(height: 12),
                _Fact(icon: Icons.score_outlined, label: '${exam.totalPoints} points'),
              ],
            ),
          ),
          const Spacer(),
          PillButton(
            label: 'Start exam',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.quiz,
              arguments: <String, dynamic>{
                'title': exam.title,
                'questions': exam.questions,
                'mockId': null,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
