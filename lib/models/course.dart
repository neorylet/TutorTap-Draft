import '../core/utils/firestore_value.dart';

class Course {
  const Course({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.description,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: stringFrom(map['id']),
      tutorId: stringFrom(map['tutorId']),
      title: stringFrom(map['title']),
      description: stringFrom(map['description']),
      subject: stringFrom(map['subject']),
      createdAt: dateTimeFromFirestore(map['createdAt']) ?? DateTime.now(),
      updatedAt: dateTimeFromFirestore(map['updatedAt']) ?? DateTime.now(),
    );
  }

  final String id;
  final String tutorId;
  final String title;
  final String description;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'tutorId': tutorId,
        'title': title,
        'description': description,
        'subject': subject,
        'createdAt': dateTimeToFirestore(createdAt),
        'updatedAt': dateTimeToFirestore(updatedAt),
      };

  Course copyWith({
    String? id,
    String? tutorId,
    String? title,
    String? description,
    String? subject,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
