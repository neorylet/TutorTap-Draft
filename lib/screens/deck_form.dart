import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/flashcard_deck.dart';
import '../providers/auth_provider.dart';
import '../providers/study_provider.dart';
import '../widgets/app_form_field.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class DeckFormScreen extends StatefulWidget {
  const DeckFormScreen({super.key, this.cardMode = false});

  final bool cardMode;

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  String? _deckId;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized || !widget.cardMode) return;
    _initialized = true;
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      _deckId = arguments;
    } else {
      final List<FlashcardDeck> decks =
          context.read<StudyProvider>().decks;
      if (decks.isNotEmpty) _deckId = decks.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: widget.cardMode ? 'Add a card' : 'New flashcard deck',
      subtitle: widget.cardMode
          ? 'Keep it short and memorable.'
          : 'Group cards by topic.',
      body: widget.cardMode ? _cardForm(context) : _deckForm(context, user),
    );
  }

  Widget _deckForm(BuildContext context, AppUser? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppFormField(
          controller: _titleController,
          label: 'Deck title',
          hint: 'Biology basics',
          prefixIcon: Icons.title_outlined,
        ),
        const SizedBox(height: 14),
        AppFormField(
          controller: _subjectController,
          label: 'Subject',
          hint: 'Biology',
          prefixIcon: Icons.book_outlined,
        ),
        const Spacer(),
        PillButton(
          label: 'Create deck',
          onPressed: user == null || _titleController.text.trim().isEmpty
              ? null
              : () async {
                  await context.read<StudyProvider>().createDeck(
                        ownerId: user.uid,
                        title: _titleController.text.trim(),
                        subject: _subjectController.text.trim().isEmpty
                            ? 'General'
                            : _subjectController.text.trim(),
                      );
                  if (context.mounted) Navigator.of(context).pop();
                },
        ),
      ],
    );
  }

  Widget _cardForm(BuildContext context) {
    final List<FlashcardDeck> decks = context.select<StudyProvider, List<FlashcardDeck>>(
      (StudyProvider provider) => provider.decks,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButtonFormField<String>(
          initialValue: _deckId,
          items: decks
              .map(
                (FlashcardDeck deck) => DropdownMenuItem<String>(
                  value: deck.id,
                  child: Text(deck.title),
                ),
              )
              .toList(growable: false),
          onChanged: (String? value) => setState(() => _deckId = value),
          decoration: const InputDecoration(labelText: 'Deck'),
        ),
        const SizedBox(height: 14),
        AppFormField(
          controller: _frontController,
          label: 'Front',
          hint: 'What is photosynthesis?',
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        AppFormField(
          controller: _backController,
          label: 'Back',
          hint: 'The process plants use to make food from light.',
          maxLines: 3,
        ),
        const Spacer(),
        PillButton(
          label: 'Add card',
          onPressed: _deckId == null || _frontController.text.trim().isEmpty
              ? null
              : () async {
                  await context.read<StudyProvider>().addCard(
                        deckId: _deckId!,
                        front: _frontController.text.trim(),
                        back: _backController.text.trim(),
                      );
                  if (context.mounted) Navigator.of(context).pop();
                },
        ),
      ],
    );
  }
}
