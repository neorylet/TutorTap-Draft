import '../core/utils/firestore_value.dart';

enum QuestionType { mcq, truefalse, short }

extension QuestionTypeX on QuestionType {
  String get value => switch (this) {
    QuestionType.mcq => 'mcq',
    QuestionType.truefalse => 'truefalse',
    QuestionType.short => 'short',
  };
}

class Question {
  const Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.choices,
    required this.points,
    this.answerIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: stringFrom(map['id']),
      type: enumFrom<QuestionType>(
        map['type'],
        <String, QuestionType>{
          'mcq': QuestionType.mcq,
          'truefalse': QuestionType.truefalse,
          'short': QuestionType.short,
        },
        QuestionType.mcq,
      ),
      prompt: stringFrom(map['prompt']),
      choices: stringListFrom(map['choices']),
      answerIndex: map['answerIndex'] == null
          ? null
          : intFrom(map['answerIndex']),
      points: intFrom(map['points'], 1),
    );
  }

  final String id;
  final QuestionType type;
  final String prompt;
  final List<String> choices;
  final int? answerIndex;
  final int points;

  bool get hasObjectiveAnswer => answerIndex != null;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'type': type.value,
    'prompt': prompt,
    'choices': choices,
    'answerIndex': answerIndex,
    'points': points,
  };

  Question copyWith({
    String? id,
    QuestionType? type,
    String? prompt,
    List<String>? choices,
    Object? answerIndex = kUnset,
    int? points,
  }) {
    return Question(
      id: id ?? this.id,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      choices: choices ?? this.choices,
      answerIndex: answerIndex == kUnset
          ? this.answerIndex
          : (answerIndex as num?)?.toInt(),
      points: points ?? this.points,
    );
  }
}
