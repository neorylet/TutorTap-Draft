import '../core/utils/firestore_value.dart';
import 'question.dart';

class ExamAttempt {
  const ExamAttempt({
    required this.studentId,
    required this.score,
    required this.at,
  });

  factory ExamAttempt.fromMap(Map<String, dynamic> map) {
    return ExamAttempt(
      studentId: stringFrom(map['studentId']),
      score: doubleFrom(map['score']),
      at: dateTimeFromFirestore(map['at']) ?? DateTime.now(),
    );
  }

  final String studentId;
  final double score;
  final DateTime at;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'studentId': studentId,
    'score': score,
    'at': dateTimeToFirestore(at),
  };

  ExamAttempt copyWith({String? studentId, double? score, DateTime? at}) {
    return ExamAttempt(
      studentId: studentId ?? this.studentId,
      score: score ?? this.score,
      at: at ?? this.at,
    );
  }
}

class Exam {
  const Exam({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.timeLimitMin,
    required this.questions,
    required this.attempts,
    this.dueDate,
    this.moduleId,
  });

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: stringFrom(map['id']),
      tutorId: stringFrom(map['tutorId']),
      title: stringFrom(map['title']),
      timeLimitMin: intFrom(map['timeLimitMin'], 15),
      dueDate: dateTimeFromFirestore(map['dueDate']),
      moduleId: map['moduleId'] as String?,
      questions: mapListFrom(map['questions'])
          .map((Map<String, dynamic> item) => Question.fromMap(item))
          .toList(growable: true),
      attempts: mapListFrom(map['attempts'])
          .map((Map<String, dynamic> item) => ExamAttempt.fromMap(item))
          .toList(growable: true),
    );
  }

  final String id;
  final String tutorId;
  final String title;
  final int timeLimitMin;
  final DateTime? dueDate;
  final String? moduleId;
  final List<Question> questions;
  final List<ExamAttempt> attempts;

  int get totalPoints =>
      questions.fold<int>(0, (int sum, Question q) => sum + q.points);

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'tutorId': tutorId,
    'title': title,
    'timeLimitMin': timeLimitMin,
    'dueDate': dateTimeToFirestore(dueDate),
    'moduleId': moduleId,
    'questions': questions
        .map((Question q) => q.toMap())
        .toList(growable: false),
    'attempts': attempts
        .map((ExamAttempt attempt) => attempt.toMap())
        .toList(growable: false),
  };

  Exam copyWith({
    String? id,
    String? tutorId,
    String? title,
    int? timeLimitMin,
    Object? dueDate = kUnset,
    Object? moduleId = kUnset,
    List<Question>? questions,
    List<ExamAttempt>? attempts,
  }) {
    return Exam(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      title: title ?? this.title,
      timeLimitMin: timeLimitMin ?? this.timeLimitMin,
      dueDate: dueDate == kUnset
          ? this.dueDate
          : dateTimeFromFirestore(dueDate),
      moduleId: moduleId == kUnset ? this.moduleId : moduleId as String?,
      questions: questions ?? this.questions,
      attempts: attempts ?? this.attempts,
    );
  }
}
