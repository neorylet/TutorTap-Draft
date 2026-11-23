import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exam.dart';
import '../models/question.dart';
import '../providers/classroom_provider.dart';
import '../widgets/due_date_tile.dart';
import 'screen_scaffold.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({
    super.key,
    required this.tutorId,
    this.moduleId,
    this.existingExam,
  });

  final String tutorId;
  final String? moduleId;
  final Exam? existingExam;

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  late final TextEditingController _titleController;
  final List<_QuestionData> _questions = <_QuestionData>[];
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _dueDate = widget.existingExam?.dueDate;
    if (widget.existingExam != null) {
      _titleController.text = widget.existingExam!.title;
      for (final Question q in widget.existingExam!.questions) {
        _questions.add(_QuestionData.fromQuestion(q));
      }
    } else {
      _addQuestion();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionData());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      if (_questions.length > 1) {
        _questions.removeAt(index);
      }
    });
  }

  bool _isValid() {
    if (_titleController.text.trim().isEmpty) return false;
    for (final _QuestionData q in _questions) {
      if (q.promptController.text.trim().isEmpty) return false;
      if (q.optionControllers.any(
        (TextEditingController c) => c.text.trim().isEmpty,
      )) {
        return false;
      }
      if (q.correctOptionIndex == null) return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_isValid()) return;

    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final List<Question> questions = _questions
        .map(
          (_QuestionData q) => Question(
            id: '',
            type: QuestionType.mcq,
            prompt: q.promptController.text.trim(),
            choices: q.optionControllers
                .map((TextEditingController c) => c.text.trim())
                .toList(),
            answerIndex: q.correctOptionIndex,
            points: 1,
          ),
        )
        .toList();

    final Exam exam = Exam(
      id: '',
      tutorId: widget.tutorId,
      title: _titleController.text.trim(),
      timeLimitMin: 15,
      questions: questions,
      attempts: <ExamAttempt>[],
      dueDate: _dueDate,
      moduleId: widget.moduleId,
    );

    final bool success = await provider.createExam(exam);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create exam: ${provider.error}')),
      );
    }
  }

  Future<void> _update() async {
    if (!_isValid()) return;

    final ClassroomProvider provider = context.read<ClassroomProvider>();
    final List<Question> questions = _questions
        .map(
          (_QuestionData q) => Question(
            id: '',
            type: QuestionType.mcq,
            prompt: q.promptController.text.trim(),
            choices: q.optionControllers
                .map((TextEditingController c) => c.text.trim())
                .toList(),
            answerIndex: q.correctOptionIndex,
            points: 1,
          ),
        )
        .toList();

    final Exam exam = widget.existingExam!.copyWith(
      title: _titleController.text.trim(),
      questions: questions,
      dueDate: _dueDate,
      moduleId: widget.moduleId,
    );

    final bool success = await provider.updateExam(exam);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update exam: ${provider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: widget.existingExam != null ? 'Edit Quiz' : 'Create Quiz',
      showBack: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DueDateTile(
              dueDate: _dueDate,
              onChanged: (DateTime? value) {
                setState(() => _dueDate = value);
              },
              isRequired: false,
              isBusy: false,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final _QuestionData q = _questions[index];
                return _QuestionCard(
                  questionIndex: index,
                  data: q,
                  onRemove: () => _removeQuestion(index),
                  onCorrectChanged: (int? newIndex) {
                    setState(() {
                      q.correctOptionIndex = newIndex;
                    });
                  },
                  onTextChanged: () => setState(() {}),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _isValid()
                  ? (widget.existingExam != null ? _update : _save)
                  : null,
              child: Text(
                widget.existingExam != null ? 'Update Quiz' : 'Save Quiz',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionData {
  _QuestionData()
    : promptController = TextEditingController(),
      optionControllers = List<TextEditingController>.generate(
        4,
        (_) => TextEditingController(),
      );

  _QuestionData.fromQuestion(Question q)
    : promptController = TextEditingController(text: q.prompt),
      optionControllers = List<TextEditingController>.generate(
        4,
        (int i) => TextEditingController(
          text: i < q.choices.length ? q.choices[i] : '',
        ),
      ),
      correctOptionIndex = q.answerIndex;

  final TextEditingController promptController;
  final List<TextEditingController> optionControllers;
  int? correctOptionIndex;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.questionIndex,
    required this.data,
    required this.onRemove,
    required this.onCorrectChanged,
    required this.onTextChanged,
  });

  final int questionIndex;
  final _QuestionData data;
  final VoidCallback onRemove;
  final ValueChanged<int?> onCorrectChanged;
  final VoidCallback onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Question ${questionIndex + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (questionIndex > 0)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: data.promptController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => onTextChanged(),
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (int optionIndex) {
              final bool isSelected = data.correctOptionIndex == optionIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.green : null,
                      ),
                      onPressed: () => onCorrectChanged(optionIndex),
                      tooltip: 'Mark as correct',
                    ),
                    Expanded(
                      child: TextField(
                        controller: data.optionControllers[optionIndex],
                        decoration: InputDecoration(
                          labelText: 'Option ${optionIndex + 1}',
                          border: const OutlineInputBorder(),
                          suffixText: isSelected ? ' ✓' : null,
                        ),
                        onChanged: (_) => onTextChanged(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
