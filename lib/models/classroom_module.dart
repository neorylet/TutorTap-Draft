import '../core/utils/firestore_value.dart';

class ClassroomModule {
  const ClassroomModule({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileType,
    required this.createdAt,
  });

  factory ClassroomModule.fromMap(Map<String, dynamic> map) {
    return ClassroomModule(
      id: stringFrom(map['id']),
      tutorId: stringFrom(map['tutorId']),
      title: stringFrom(map['title']),
      description: stringFrom(map['description']),
      fileUrl: stringFrom(map['fileUrl']),
      fileType: stringFrom(map['fileType']),
      createdAt: dateTimeFromFirestore(map['createdAt']) ?? DateTime.now(),
    );
  }

  final String id;
  final String tutorId;
  final String title;
  final String description;
  final String fileUrl;
  final String fileType;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'tutorId': tutorId,
    'title': title,
    'description': description,
    'fileUrl': fileUrl,
    'fileType': fileType,
    'createdAt': dateTimeToFirestore(createdAt),
  };

  ClassroomModule copyWith({
    String? id,
    String? tutorId,
    String? title,
    String? description,
    String? fileUrl,
    String? fileType,
    DateTime? createdAt,
  }) {
    return ClassroomModule(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
