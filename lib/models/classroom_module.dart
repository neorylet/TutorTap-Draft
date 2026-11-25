import '../core/utils/firestore_value.dart';
import 'module_file.dart';

class ClassroomModule {
  const ClassroomModule({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.files = const <ModuleFile>[],
    this.courseId,
    this.orderIndex = 0,
  });

  factory ClassroomModule.fromMap(Map<String, dynamic> map) {
    return ClassroomModule(
      id: stringFrom(map['id']),
      tutorId: stringFrom(map['tutorId']),
      title: stringFrom(map['title']),
      description: stringFrom(map['description']),
      createdAt: dateTimeFromFirestore(map['createdAt']) ?? DateTime.now(),
      files: _filesFrom(map),
      courseId: map['courseId'] as String?,
      orderIndex: intFrom(map['orderIndex'], 0),
    );
  }

  final String id;
  final String tutorId;
  final String title;
  final String description;
  final List<ModuleFile> files;
  final DateTime createdAt;
  final String? courseId;
  final int orderIndex;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'tutorId': tutorId,
    'title': title,
    'description': description,
    'files': files.map((ModuleFile f) => f.toMap()).toList(),
    'createdAt': dateTimeToFirestore(createdAt),
    'courseId': courseId,
    'orderIndex': orderIndex,
  };

  ClassroomModule copyWith({
    String? id,
    String? tutorId,
    String? title,
    String? description,
    List<ModuleFile>? files,
    DateTime? createdAt,
    Object? courseId = kUnset,
    int? orderIndex,
  }) {
    return ClassroomModule(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      title: title ?? this.title,
      description: description ?? this.description,
      files: files ?? this.files,
      createdAt: createdAt ?? this.createdAt,
      courseId: courseId == kUnset ? this.courseId : courseId as String?,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  static List<ModuleFile> _filesFrom(Map<String, dynamic> map) {
    final Object? raw = map['files'];
    if (raw is List && raw.isNotEmpty) {
      final List<ModuleFile> parsed = raw
          .whereType<Map<Object?, Object?>>()
          .map((e) => ModuleFile.fromMap(Map<String, dynamic>.from(e)))
          .where((ModuleFile f) => f.url.isNotEmpty)
          .toList(growable: false);
      if (parsed.isNotEmpty) return parsed;
    }
    // Legacy single-file documents.
    final String legacyUrl = stringFrom(map['fileUrl']);
    if (legacyUrl.isEmpty) return const <ModuleFile>[];
    final String legacyType = stringFrom(map['fileType']);
    return <ModuleFile>[
      ModuleFile(
        url: legacyUrl,
        type: legacyType,
        name: _nameFromUrl(legacyUrl, legacyType),
      ),
    ];
  }

  static String _nameFromUrl(String url, String type) {
    final List<String> segments = Uri.parse(url).pathSegments;
    if (segments.isEmpty) {
      return type.isEmpty ? 'Document' : 'Document.${type.toLowerCase()}';
    }
    return Uri.decodeComponent(segments.last);
  }
}
