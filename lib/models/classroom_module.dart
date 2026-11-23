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
    this.courseId,
    this.orderIndex = 0,
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
      courseId: map['courseId'] as String?,
      orderIndex: intFrom(map['orderIndex'], 0),
    );
  }

  final String id;
  final String tutorId;
  final String title;
  final String description;
  final String fileUrl;
  // Accepted values: 'pdf', 'ppt', 'pptx'
  final String fileType;
  final DateTime createdAt;
  final String? courseId;
  final int orderIndex;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'tutorId': tutorId,
    'title': title,
    'description': description,
    'fileUrl': fileUrl,
    'fileType': fileType,
    'createdAt': dateTimeToFirestore(createdAt),
    'courseId': courseId,
    'orderIndex': orderIndex,
  };

  ClassroomModule copyWith({
    String? id,
    String? tutorId,
    String? title,
    String? description,
    String? fileUrl,
    String? fileType,
    DateTime? createdAt,
    Object? courseId = kUnset,
    int? orderIndex,
  }) {
    return ClassroomModule(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      courseId: courseId == kUnset ? this.courseId : courseId as String?,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
