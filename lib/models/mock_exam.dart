import '../core/utils/firestore_value.dart';
import 'question.dart';

class MockExam {
  const MockExam({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.timeLimitMin,
    required this.questions,
    this.lastScore,
  });

  factory MockExam.fromMap(Map<String, dynamic> map) {
    return MockExam(
      id: stringFrom(map['id']),
      ownerId: stringFrom(map['ownerId']),
      title: stringFrom(map['title']),
      timeLimitMin: intFrom(map['timeLimitMin'], 15),
      questions: mapListFrom(map['questions'])
          .map((Map<String, dynamic> item) => Question.fromMap(item))
          .toList(growable: true),
      lastScore: map['lastScore'] == null
          ? null
          : doubleFrom(map['lastScore']),
    );
  }

  final String id;
  final String ownerId;
  final String title;
  final int timeLimitMin;
  final List<Question> questions;
  final double? lastScore;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'timeLimitMin': timeLimitMin,
    'questions': questions.map((Question q) => q.toMap()).toList(growable: false),
    'lastScore': lastScore,
  };

  MockExam copyWith({
    String? id,
    String? ownerId,
    String? title,
    int? timeLimitMin,
    List<Question>? questions,
    Object? lastScore = kUnset,
  }) {
    return MockExam(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      timeLimitMin: timeLimitMin ?? this.timeLimitMin,
      questions: questions ?? this.questions,
      lastScore: lastScore == kUnset
          ? this.lastScore
          : (lastScore as num?)?.toDouble(),
    );
  }
}
