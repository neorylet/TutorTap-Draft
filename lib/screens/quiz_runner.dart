import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/study_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/progress_bar.dart';
import 'screen_scaffold.dart';

class QuizRunnerScreen extends StatefulWidget {
  const QuizRunnerScreen({super.key});

  @override
  State<QuizRunnerScreen> createState() => _QuizRunnerScreenState();
}

class _QuizRunnerScreenState extends State<QuizRunnerScreen> {
  bool _initialized = false;
  String? _mockId;
  String _title = 'Quiz';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _title = arguments['title'] as String? ?? 'Quiz';
      _mockId = arguments['mockId'] as String?;
      final List<Question> questions = (arguments['questions'] as List<Question>?) ??
          const <Question>[];
      context.read<StudyProvider>().startQuiz(title: _title, questions: questions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Question? question = context.select<StudyProvider, Question?>(
      (StudyProvider provider) => provider.currentQuestion,
    );
    final int index = context.select<StudyProvider, int>(
      (StudyProvider provider) => provider.questionIndex,
    );
    final int total = context.select<StudyProvider, int>(
      (StudyProvider provider) => provider.quizQuestions.length,
    );
    final int? answer = context.select<StudyProvider, int?>(
      (StudyProvider provider) => provider.answerAt(provider.questionIndex),
    );
    final bool finished = context.select<StudyProvider, bool>(
      (StudyProvider provider) => provider.quizFinished,
    );
    final double? score = context.select<StudyProvider, double?>(
      (StudyProvider provider) => provider.lastScore,
    );

    if (finished) {
      return ScreenScaffold(
        title: 'Quiz complete',
        subtitle: _title,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionCard(
              child: Column(
                children: <Widget>[
                  Text(
                    '${score?.toStringAsFixed(0) ?? '0'} pts',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Answer review will be available in Phase 2.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.studySummary,
                arguments: <String, dynamic>{
                  'title': _title,
                  'score': score ?? 0.0,
                  'mockId': _mockId,
                },
              ),
              child: const Text('View summary'),
            ),
          ],
        ),
      );
    }

    if (question == null) {
      return const ScreenScaffold(
        title: 'Quiz',
        body: EmptyHint(message: 'This quiz has no questions yet.'),
      );
    }

    return ScreenScaffold(
      title: _title,
      subtitle: 'Question ${index + 1} of $total',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProgressBar(value: total == 0 ? 0 : (index + 1) / total),
          const SizedBox(height: 18),
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: question.choices.length,
              itemBuilder: (BuildContext context, int choiceIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChoiceCard(
                    label: question.choices[choiceIndex],
                    selected: answer == choiceIndex,
                    onTap: () => context
                        .read<StudyProvider>()
                        .answerCurrent(choiceIndex),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: context.read<StudyProvider>().nextQuestion,
            child: Text(index + 1 >= total ? 'Finish quiz' : 'Next question'),
          ),
        ],
      ),
    );
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).cardColor,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label),
      ),
    );
  }
}
