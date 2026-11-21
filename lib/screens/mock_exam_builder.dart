import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/question.dart';
import '../providers/auth_provider.dart';
import '../providers/study_provider.dart';
import '../widgets/app_form_field.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class MockExamBuilderScreen extends StatefulWidget {
  const MockExamBuilderScreen({super.key});

  @override
  State<MockExamBuilderScreen> createState() => _MockExamBuilderScreenState();
}

class _MockExamBuilderScreenState extends State<MockExamBuilderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _choiceControllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController _promptController = TextEditingController();
  int _timeLimit = 15;
  int _answerIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    for (final TextEditingController controller in _choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: 'Build a mock exam',
      subtitle: 'Start with one multiple-choice question.',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppFormField(
              controller: _titleController,
              label: 'Exam title',
              hint: 'Algebra practice',
              prefixIcon: Icons.title_outlined,
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Time limit: $_timeLimit min',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _timeLimit > 5
                      ? () => setState(() => _timeLimit -= 5)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _timeLimit += 5),
                ),
              ],
            ),
            const Divider(height: 22),
            AppFormField(
              controller: _promptController,
              label: 'Question',
              hint: 'What is 7 × 8?',
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            RadioGroup<int>(
              groupValue: _answerIndex,
              onChanged: (int? value) =>
                  setState(() => _answerIndex = value ?? 0),
              child: Column(
                children: <Widget>[
                  for (int index = 0; index < _choiceControllers.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Radio<int>(value: index),
                        title: AppFormField(
                          controller: _choiceControllers[index],
                          hint: 'Option ${index + 1}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PillButton(
              label: 'Save mock exam',
              onPressed: user == null ||
                      _titleController.text.trim().isEmpty ||
                      _promptController.text.trim().isEmpty
                  ? null
                  : () => _save(user.uid),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(String ownerId) async {
    final List<String> choices = _choiceControllers
        .map((TextEditingController controller) => controller.text.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
    if (choices.isEmpty) return;
    final Question question = Question(
      id: 'q-${DateTime.now().microsecondsSinceEpoch}',
      type: QuestionType.mcq,
      prompt: _promptController.text.trim(),
      choices: choices,
      answerIndex: _answerIndex < choices.length ? _answerIndex : 0,
      points: 1,
    );
    final StudyProvider study = context.read<StudyProvider>();
    await study.createMockExam(
      ownerId: ownerId,
      title: _titleController.text.trim(),
      timeLimitMin: _timeLimit,
      questions: <Question>[question],
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
