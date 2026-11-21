import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flashcard_deck.dart';
import '../providers/study_provider.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class FlashcardRunnerScreen extends StatefulWidget {
  const FlashcardRunnerScreen({super.key});

  @override
  State<FlashcardRunnerScreen> createState() => _FlashcardRunnerScreenState();
}

class _FlashcardRunnerScreenState extends State<FlashcardRunnerScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      context.read<StudyProvider>().startDeck(arguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FlashcardDeck? deck = context.select<StudyProvider, FlashcardDeck?>(
      (StudyProvider provider) {
        final String? id = provider.activeDeckId;
        if (id == null) return null;
        for (final FlashcardDeck item in provider.decks) {
          if (item.id == id) return item;
        }
        return null;
      },
    );
    final int queueLength = context.select<StudyProvider, int>(
      (StudyProvider provider) => provider.queueLength,
    );
    final bool isFlipped = context.select<StudyProvider, bool>(
      (StudyProvider provider) => provider.isFlipped,
    );
    final String? front = context.select<StudyProvider, String?>(
      (StudyProvider provider) => provider.currentCard?.front,
    );
    final String? back = context.select<StudyProvider, String?>(
      (StudyProvider provider) => provider.currentCard?.back,
    );

    return ScreenScaffold(
      title: deck?.title ?? 'Flashcards',
      subtitle: '$queueLength card${queueLength == 1 ? '' : 's'} left',
      body: queueLength == 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const LottiePlaceholder(),
                const SizedBox(height: 12),
                Text(
                  'All done for this deck.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                PillButton(
                  label: 'Back to study studio',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: context.read<StudyProvider>().flipCard,
                    child: SectionCard(
                      child: Center(
                        child: Text(
                          isFlipped ? (back ?? '') : (front ?? ''),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap the card to ${isFlipped ? 'hide' : 'reveal'} the answer.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PillButton(
                        label: 'Review again',
                        variant: PillButtonVariant.amber,
                        onPressed: () => _answer(FlashcardState.reviewAgain),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PillButton(
                        label: 'Mastered',
                        onPressed: () => _answer(FlashcardState.mastered),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _answer(FlashcardState state) async {
    await context.read<StudyProvider>().answerCard(state);
  }
}

class LottiePlaceholder extends StatelessWidget {
  const LottiePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 42,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
