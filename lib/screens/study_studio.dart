import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/flashcard_deck.dart';
import '../models/mock_exam.dart';
import '../providers/auth_provider.dart';
import '../providers/study_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/progress_bar.dart';
import 'screen_scaffold.dart';

class StudyStudioScreen extends StatefulWidget {
  const StudyStudioScreen({super.key});

  @override
  State<StudyStudioScreen> createState() => _StudyStudioScreenState();
}

class _StudyStudioScreenState extends State<StudyStudioScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<StudyProvider>().watchStudy(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FlashcardDeck> decks = context.select<StudyProvider, List<FlashcardDeck>>(
      (StudyProvider provider) => provider.decks,
    );
    final List<MockExam> exams = context.select<StudyProvider, List<MockExam>>(
      (StudyProvider provider) => provider.mockExams,
    );
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: 'Study studio',
      subtitle: user == null ? 'Sign in to save your study sets.' : 'Your decks and practice exams.',
      showBack: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.deckForm),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Flashcard decks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (decks.isEmpty)
              const EmptyHint(message: 'Create a deck to start revising.')
            else
              ...decks.map(
                (FlashcardDeck deck) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      context.read<StudyProvider>().startDeck(deck.id);
                      Navigator.of(context).pushNamed(
                        AppRoutes.flashcards,
                        arguments: deck.id,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(deck.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            deck.subject,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          ProgressBar(
                            value: deck.cards.isEmpty
                                ? 0
                                : deck.masteredCount / deck.cards.length,
                            caption: '${deck.masteredCount}/${deck.cards.length} mastered',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text('Mock exams', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (exams.isEmpty)
              const EmptyHint(message: 'Build a practice exam when you are ready.')
            else
              ...exams.map(
                (MockExam exam) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      final StudyProvider study = context.read<StudyProvider>();
                      study.startQuiz(title: exam.title, questions: exam.questions);
                      Navigator.of(context).pushNamed(
                        AppRoutes.quiz,
                        arguments: <String, dynamic>{
                          'title': exam.title,
                          'questions': exam.questions,
                          'mockId': exam.id,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.quiz_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(exam.title, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  '${exam.questions.length} questions · ${exam.timeLimitMin} min',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (exam.lastScore != null)
                            Text(
                              '${exam.lastScore!.toStringAsFixed(0)} pts',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.mockBuilder),
              icon: const Icon(Icons.add),
              label: const Text('Build a mock exam'),
            ),
          ],
        ),
      ),
    );
  }
}
