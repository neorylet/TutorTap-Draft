import '../core/utils/firestore_value.dart';

enum FlashcardState { newCard, reviewAgain, mastered }

extension FlashcardStateX on FlashcardState {
  String get value => switch (this) {
    FlashcardState.newCard => 'new',
    FlashcardState.reviewAgain => 'review_again',
    FlashcardState.mastered => 'mastered',
  };
}

class Flashcard {
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.state,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: stringFrom(map['id']),
      front: stringFrom(map['front']),
      back: stringFrom(map['back']),
      state: enumFrom<FlashcardState>(
        map['state'],
        <String, FlashcardState>{
          'new': FlashcardState.newCard,
          'newcard': FlashcardState.newCard,
          'review_again': FlashcardState.reviewAgain,
          'reviewagain': FlashcardState.reviewAgain,
          'mastered': FlashcardState.mastered,
        },
        FlashcardState.newCard,
      ),
    );
  }

  final String id;
  final String front;
  final String back;
  final FlashcardState state;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'front': front,
    'back': back,
    'state': state.value,
  };

  Flashcard copyWith({String? id, String? front, String? back, FlashcardState? state}) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      state: state ?? this.state,
    );
  }
}

class FlashcardDeck {
  const FlashcardDeck({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.subject,
    required this.cards,
  });

  factory FlashcardDeck.fromMap(Map<String, dynamic> map) {
    return FlashcardDeck(
      id: stringFrom(map['id']),
      ownerId: stringFrom(map['ownerId']),
      title: stringFrom(map['title']),
      subject: stringFrom(map['subject']),
      cards: mapListFrom(map['cards'])
          .map((Map<String, dynamic> item) => Flashcard.fromMap(item))
          .toList(growable: true),
    );
  }

  final String id;
  final String ownerId;
  final String title;
  final String subject;
  final List<Flashcard> cards;

  int get masteredCount => cards
      .where((Flashcard card) => card.state == FlashcardState.mastered)
      .length;

  int get reviewCount => cards
      .where((Flashcard card) => card.state == FlashcardState.reviewAgain)
      .length;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'subject': subject,
    'cards': cards.map((Flashcard card) => card.toMap()).toList(growable: false),
  };

  FlashcardDeck copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? subject,
    List<Flashcard>? cards,
  }) {
    return FlashcardDeck(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      cards: cards ?? this.cards,
    );
  }
}
