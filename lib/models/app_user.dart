import '../core/utils/firestore_value.dart';

enum UserRole { student, tutor }

extension UserRoleX on UserRole {
  String get value => switch (this) {
    UserRole.student => 'student',
    UserRole.tutor => 'tutor',
  };
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role,
    this.photoUrl,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final String? roleValue = map['role']?.toString();
    UserRole? role;
    if (roleValue != null && roleValue.isNotEmpty) {
      role = enumFrom<UserRole>(roleValue, <String, UserRole>{
        'student': UserRole.student,
        'tutor': UserRole.tutor,
      }, UserRole.student);
    }
    return AppUser(
      uid: stringFrom(map['uid']),
      email: stringFrom(map['email']),
      displayName: stringFrom(map['displayName']),
      role: role,
      photoUrl: map['photoUrl'] as String?,
      createdAt: dateTimeFromFirestore(map['createdAt']),
    );
  }

  final String uid;
  final String email;
  final String displayName;
  final UserRole? role;
  final String? photoUrl;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'role': role?.value,
    'photoUrl': photoUrl,
    'createdAt': dateTimeToFirestore(createdAt),
  };

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    Object? photoUrl = kUnset,
    Object? createdAt = kUnset,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoUrl: photoUrl == kUnset ? this.photoUrl : photoUrl as String?,
      createdAt: createdAt == kUnset
          ? this.createdAt
          : dateTimeFromFirestore(createdAt),
    );
  }
}
