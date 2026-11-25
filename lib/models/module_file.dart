import '../core/utils/firestore_value.dart';

/// One document attached to a classroom module.
class ModuleFile {
  const ModuleFile({
    required this.url,
    required this.type,
    required this.name,
    this.publicId = '',
  });

  factory ModuleFile.fromMap(Map<String, dynamic> map) {
    return ModuleFile(
      url: stringFrom(map['url']),
      type: stringFrom(map['type']),
      name: stringFrom(map['name']),
      publicId: stringFrom(map['publicId']),
    );
  }

  final String url;
  // Lowercase extension: 'pdf', 'ppt', 'pptx', 'doc', 'docx', 'image', ...
  final String type;
  final String name;

  /// Cloudinary public_id. Empty for legacy documents and seeded data.
  /// Removing a document from a module does NOT delete the Cloudinary
  /// asset; this is what a server-side purge needs (Admin API destroy).
  final String publicId;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'url': url,
    'type': type,
    'name': name,
    'publicId': publicId,
  };
}
