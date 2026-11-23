import '../core/utils/firestore_value.dart';

enum AssignmentStatus { assigned, submitted, graded }

extension AssignmentStatusX on AssignmentStatus {
  String get value => switch (this) {
    AssignmentStatus.assigned => 'assigned',
    AssignmentStatus.submitted => 'submitted',
    AssignmentStatus.graded => 'graded',
  };
}

class Assignment {
  const Assignment({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.title,
    required this.instructions,
    required this.dueDate,
    required this.maxScore,
    required this.status,
    this.attachmentUrl,
    this.attachmentType,
    this.submissionUrl,
    this.submissionText,
    this.submittedAt,
    this.grade,
    this.feedback,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: stringFrom(map['id']),
      tutorId: stringFrom(map['tutorId']),
      studentId: stringFrom(map['studentId']),
      title: stringFrom(map['title']),
      instructions: stringFrom(map['instructions']),
      dueDate: dateTimeFromFirestore(map['dueDate']) ?? DateTime.now(),
      attachmentUrl: map['attachmentUrl'] as String?,
      attachmentType: map['attachmentType'] as String?,
      submissionUrl: map['submissionUrl'] as String?,
      submissionText: map['submissionText'] as String?,
      submittedAt: dateTimeFromFirestore(map['submittedAt']),
      grade: map['grade'] == null ? null : doubleFrom(map['grade']),
      maxScore: doubleFrom(map['maxScore'], 10),
      feedback: map['feedback'] as String?,
      status: enumFrom<AssignmentStatus>(
        map['status'],
        <String, AssignmentStatus>{
          'assigned': AssignmentStatus.assigned,
          'submitted': AssignmentStatus.submitted,
          'graded': AssignmentStatus.graded,
        },
        AssignmentStatus.assigned,
      ),
    );
  }

  final String id;
  final String tutorId;
  final String studentId;
  final String title;
  final String instructions;
  final DateTime dueDate;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? submissionUrl;
  final String? submissionText;
  final DateTime? submittedAt;
  final double? grade;
  final double maxScore;
  final String? feedback;
  final AssignmentStatus status;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'tutorId': tutorId,
    'studentId': studentId,
    'title': title,
    'instructions': instructions,
    'dueDate': dateTimeToFirestore(dueDate),
    'attachmentUrl': attachmentUrl,
    'attachmentType': attachmentType,
    'submissionUrl': submissionUrl,
    'submissionText': submissionText,
    'submittedAt': dateTimeToFirestore(submittedAt),
    'grade': grade,
    'maxScore': maxScore,
    'feedback': feedback,
    'status': status.value,
  };

  Assignment copyWith({
    String? id,
    String? tutorId,
    String? studentId,
    String? title,
    String? instructions,
    DateTime? dueDate,
    Object? attachmentUrl = kUnset,
    Object? attachmentType = kUnset,
    Object? submissionUrl = kUnset,
    Object? submissionText = kUnset,
    Object? submittedAt = kUnset,
    Object? grade = kUnset,
    double? maxScore,
    Object? feedback = kUnset,
    AssignmentStatus? status,
  }) {
    return Assignment(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      dueDate: dueDate ?? this.dueDate,
      attachmentUrl: attachmentUrl == kUnset
          ? this.attachmentUrl
          : attachmentUrl as String?,
      attachmentType: attachmentType == kUnset
          ? this.attachmentType
          : attachmentType as String?,
      submissionUrl: submissionUrl == kUnset
          ? this.submissionUrl
          : submissionUrl as String?,
      submissionText: submissionText == kUnset
          ? this.submissionText
          : submissionText as String?,
      submittedAt: submittedAt == kUnset
          ? this.submittedAt
          : dateTimeFromFirestore(submittedAt),
      grade: grade == kUnset ? this.grade : (grade as num?)?.toDouble(),
      maxScore: maxScore ?? this.maxScore,
      feedback: feedback == kUnset ? this.feedback : feedback as String?,
      status: status ?? this.status,
    );
  }
}
