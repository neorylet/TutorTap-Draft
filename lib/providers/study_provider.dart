import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/flashcard_deck.dart';
import '../models/mock_exam.dart';
import '../models/question.dart';
import '../services/firestore_service.dart';

/// A flashcard screen should watch only `currentCard`, `queueLength` and
/// `isFlipped` with `context.select`; the quiz runner watches `currentQuestion`.
class StudyProvider extends ChangeNotifier {
  StudyProvider(this._firestoreService);

  final FirestoreService _firestoreService;
  StreamSubscription<List<FlashcardDeck>>? _decksSubscription;
  StreamSubscription<List<MockExam>>? _mockExamsSubscription;

  List<FlashcardDeck> _decks = <FlashcardDeck>[];
  List<MockExam> _mockExams = <MockExam>[];
  List<Flashcard> _reviewQueue = <Flashcard>[];
  List<Question> _quizQuestions = <Question>[];
  final List<int?> _answers = <int?>[];

  String? _activeDeckId;
  String _quizTitle = '';
  int _questionIndex = 0;
  bool _isFlipped = false;
  bool _isSavingCard = false;
  bool _quizFinished = false;
  double? _lastScore;
  String? _error;
  bool _disposed = false;

  List<FlashcardDeck> get decks => _decks;
  List<MockExam> get mockExams => _mockExams;
  String? get activeDeckId => _activeDeckId;
  Flashcard? get currentCard => _reviewQueue.isEmpty ? null : _reviewQueue.first;
  int get queueLength => _reviewQueue.length;
  bool get isFlipped => _isFlipped;
  bool get isSavingCard => _isSavingCard;
  String get quizTitle => _quizTitle;
  List<Question> get quizQuestions => _quizQuestions;
  int get questionIndex => _questionIndex;
  bool get quizFinished => _quizFinished;
  double? get lastScore => _lastScore;
  String? get error => _error;

  Question? get currentQuestion =>
      _questionIndex < _quizQuestions.length ? _quizQuestions[_questionIndex] : null;

  int get answeredCount =>
      _answers.where((int? answer) => answer != null).length;

  int? answerAt(int index) =>
      index >= 0 && index < _answers.length ? _answers[index] : null;

  void watchStudy(String ownerId) {
    _decksSubscription?.cancel();
    _mockExamsSubscription?.cancel();
    _decksSubscription = _firestoreService.watchDecks(ownerId).listen((decks) {
      _decks = decks;
      _notify();
    });
    _mockExamsSubscription = _firestoreService
        .watchMockExams(ownerId)
        .listen((exams) {
          _mockExams = exams;
          _notify();
        });
  }

  Future<void> createDeck({
    required String ownerId,
    required String title,
    required String subject,
  }) async {
    await _firestoreService.addDeck(
      FlashcardDeck(
        id: '',
        ownerId: ownerId,
        title: title,
        subject: subject,
        cards: <Flashcard>[],
      ),
    );
  }

  Future<void> addCard({
    required String deckId,
    required String front,
    required String back,
  }) async {
    final int index = _decks.indexWhere((FlashcardDeck deck) => deck.id == deckId);
    if (index < 0) return;
    final FlashcardDeck deck = _decks[index];
    final List<Flashcard> cards = List<Flashcard>.from(deck.cards)
      ..add(
        Flashcard(
          id: 'card-${DateTime.now().microsecondsSinceEpoch}',
          front: front,
          back: back,
          state: FlashcardState.newCard,
        ),
      );
    await _firestoreService.updateDeck(
      deckId,
      deck.copyWith(cards: cards),
    );
  }

  void startDeck(String deckId) {
    final FlashcardDeck? deck = _decks.cast<FlashcardDeck?>().firstWhere(
      (FlashcardDeck? item) => item?.id == deckId,
      orElse: () => null,
    );
    if (deck == null) return;
    _activeDeckId = deckId;
    _reviewQueue = List<Flashcard>.from(deck.cards);
    _isFlipped = false;
    _notify();
  }

  void flipCard() {
    if (_reviewQueue.isEmpty) return;
    _isFlipped = !_isFlipped;
    _notify();
  }

  /// Simple two-state queue: mastered cards leave the queue, cards marked
  /// review-again go to the back. No spaced-repetition scheduling in Phase 1.
  Future<void> answerCard(FlashcardState state) async {
    if (_reviewQueue.isEmpty || _isSavingCard) return;
    final Flashcard card = _reviewQueue.removeAt(0);
    final Flashcard updated = card.copyWith(state: state);
    if (state == FlashcardState.reviewAgain) {
      _reviewQueue.add(updated);
    }
    _isFlipped = false;
    _notify();
    await _persistCardState(updated);
  }

  void startQuiz({required String title, required List<Question> questions}) {
    _quizTitle = title;
    _quizQuestions = List<Question>.from(questions);
    _answers
      ..clear()
      ..addAll(List<int?>.filled(questions.length, null));
    _questionIndex = 0;
    _quizFinished = false;
    _lastScore = null;
    _error = null;
    _notify();
  }

  void answerCurrent(int choiceIndex) {
    if (_questionIndex >= _answers.length) return;
    _answers[_questionIndex] = choiceIndex;
    _notify();
  }

  void nextQuestion() {
    if (_questionIndex + 1 >= _quizQuestions.length) {
      finishQuiz();
      return;
    }
    _questionIndex += 1;
    _notify();
  }

  void finishQuiz() {
    int earned = 0;
    int possible = 0;
    for (int index = 0; index < _quizQuestions.length; index++) {
      final Question question = _quizQuestions[index];
      final int? expected = question.answerIndex;
      if (expected == null) continue;
      possible += question.points;
      if (_answers[index] == expected) earned += question.points;
    }
    _lastScore = possible == 0 ? 0 : earned.toDouble();
    _quizFinished = true;
    _notify();
  }

  Future<void> saveMockExamScore(String mockId) async {
    final int index = _mockExams.indexWhere(
      (MockExam exam) => exam.id == mockId,
    );
    if (index < 0 || _lastScore == null) return;
    final MockExam exam = _mockExams[index];
    await _firestoreService.updateMockExam(
      mockId,
      exam.copyWith(lastScore: _lastScore),
    );
  }

  Future<void> createMockExam({
    required String ownerId,
    required String title,
    required int timeLimitMin,
    required List<Question> questions,
  }) async {
    await _firestoreService.addMockExam(
      MockExam(
        id: '',
        ownerId: ownerId,
        title: title,
        timeLimitMin: timeLimitMin,
        questions: questions,
      ),
    );
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  Future<void> _persistCardState(Flashcard updated) async {
    if (_activeDeckId == null) return;
    final int deckIndex = _decks.indexWhere(
      (FlashcardDeck deck) => deck.id == _activeDeckId,
    );
    if (deckIndex < 0) return;
    final FlashcardDeck deck = _decks[deckIndex];
    final List<Flashcard> cards = deck.cards
        .map(
          (Flashcard card) => card.id == updated.id ? updated : card,
        )
        .toList(growable: false);

    _isSavingCard = true;
    _notify();
    try {
      await _firestoreService.updateDeck(
        deck.id,
        deck.copyWith(cards: cards),
      );
    } catch (error) {
      _error = error.toString();
    } finally {
      _isSavingCard = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _decksSubscription?.cancel();
    _mockExamsSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }
}
