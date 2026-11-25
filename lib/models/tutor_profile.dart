import '../core/utils/firestore_value.dart';
import 'time_slot.dart';

enum VerificationStatus { pending, verified, rejected }

extension VerificationStatusX on VerificationStatus {
  String get value => switch (this) {
    VerificationStatus.pending => 'pending',
    VerificationStatus.verified => 'verified',
    VerificationStatus.rejected => 'rejected',
  };
}

class TutorExperience {
  const TutorExperience({
    required this.role,
    required this.organization,
    required this.startYear,
    required this.endYear,
    required this.description,
  });

  factory TutorExperience.fromMap(Map<String, dynamic> map) {
    return TutorExperience(
      role: stringFrom(map['role']),
      organization: stringFrom(map['organization']),
      startYear: intFrom(map['startYear']),
      endYear: intFrom(map['endYear']),
      description: stringFrom(map['description']),
    );
  }

  final String role;
  final String organization;
  final int startYear;
  final int endYear;
  final String description;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'role': role,
    'organization': organization,
    'startYear': startYear,
    'endYear': endYear,
    'description': description,
  };
}

class TutorEducation {
  const TutorEducation({
    required this.school,
    required this.degree,
    required this.year,
  });

  factory TutorEducation.fromMap(Map<String, dynamic> map) {
    return TutorEducation(
      school: stringFrom(map['school']),
      degree: stringFrom(map['degree']),
      year: intFrom(map['year']),
    );
  }

  final String school;
  final String degree;
  final int year;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'school': school,
    'degree': degree,
    'year': year,
  };
}

class TutorCertification {
  const TutorCertification({
    required this.name,
    required this.issuer,
    required this.year,
  });

  factory TutorCertification.fromMap(Map<String, dynamic> map) {
    return TutorCertification(
      name: stringFrom(map['name']),
      issuer: stringFrom(map['issuer']),
      year: intFrom(map['year']),
    );
  }

  final String name;
  final String issuer;
  final int year;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'name': name,
    'issuer': issuer,
    'year': year,
  };
}

class TutorProfile {
  const TutorProfile({
    required this.uid,
    required this.displayName,
    required this.headline,
    required this.bio,
    required this.subjectsList,
    required this.languages,
    required this.teachingMode,
    required this.experienceYears,
    required this.experience,
    required this.education,
    required this.certifications,
    required this.hourlyRate,
    required this.rating,
    required this.ratingCount,
    required this.verificationStatus,
    required this.slots,
    this.avatarUrl,
    this.avatarPublicId = '',
    this.updatedAt,
  });

  factory TutorProfile.fromMap(Map<String, dynamic> map) {
    return TutorProfile(
      uid: stringFrom(map['uid']),
      displayName: stringFrom(map['displayName']),
      headline: stringFrom(map['headline']),
      bio: stringFrom(map['bio']),
      subjectsList: stringListFrom(map['subjects']),
      languages: stringListFrom(map['languages']),
      teachingMode: stringFrom(map['teachingMode'], 'online'),
      experienceYears: intFrom(map['experienceYears']),
      experience: mapListFrom(map['experience'])
          .map(TutorExperience.fromMap)
          .toList(growable: false),
      education: mapListFrom(map['education'])
          .map(TutorEducation.fromMap)
          .toList(growable: false),
      certifications: mapListFrom(map['certifications'])
          .map(TutorCertification.fromMap)
          .toList(growable: false),
      hourlyRate: doubleFrom(map['hourlyRate']),
      rating: doubleFrom(map['rating']),
      ratingCount: intFrom(map['ratingCount']),
      verificationStatus: enumFrom<VerificationStatus>(
        map['verificationStatus'],
        <String, VerificationStatus>{
          'pending': VerificationStatus.pending,
          'verified': VerificationStatus.verified,
          'rejected': VerificationStatus.rejected,
        },
        VerificationStatus.pending,
      ),
      avatarUrl: map['avatarUrl'] as String?,
      avatarPublicId: stringFrom(map['avatarPublicId']),
      updatedAt: dateTimeFromFirestore(map['updatedAt']),
      slots: mapListFrom(map['slots'])
          .map(TimeSlot.fromMap)
          .toList(growable: true),
    );
  }

  final String uid;
  final String displayName;
  final String headline;
  final String bio;
  final List<String> subjectsList;
  final List<String> languages;
  final String teachingMode; // 'online' | 'in-person' | 'both'
  final int experienceYears;
  final List<TutorExperience> experience;
  final List<TutorEducation> education;
  final List<TutorCertification> certifications;
  final double hourlyRate;
  final double rating;
  final int ratingCount;
  final VerificationStatus verificationStatus;
  final String? avatarUrl;
  final String avatarPublicId;
  final DateTime? updatedAt;
  final List<TimeSlot> slots;

  // Compatibility for existing code paths.
  List<String> get subjects => subjectsList;

  String get initials {
    final List<String> parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'uid': uid,
    'displayName': displayName,
    'headline': headline,
    'bio': bio,
    'subjects': subjectsList,
    'languages': languages,
    'teachingMode': teachingMode,
    'experienceYears': experienceYears,
    'experience': experience.map((e) => e.toMap()).toList(growable: false),
    'education': education.map((e) => e.toMap()).toList(growable: false),
    'certifications':
        certifications.map((e) => e.toMap()).toList(growable: false),
    'hourlyRate': hourlyRate,
    'rating': rating,
    'ratingCount': ratingCount,
    'verificationStatus': verificationStatus.value,
    'avatarUrl': avatarUrl,
    'avatarPublicId': avatarPublicId,
    'updatedAt': updatedAt,
    'slots': slots.map((TimeSlot slot) => slot.toMap()).toList(growable: false),
  };

  TutorProfile copyWith({
    String? uid,
    String? displayName,
    String? headline,
    String? bio,
    List<String>? subjectsList,
    List<String>? languages,
    String? teachingMode,
    int? experienceYears,
    List<TutorExperience>? experience,
    List<TutorEducation>? education,
    List<TutorCertification>? certifications,
    double? hourlyRate,
    double? rating,
    int? ratingCount,
    VerificationStatus? verificationStatus,
    Object? avatarUrl = kUnset,
    String? avatarPublicId,
    Object? updatedAt = kUnset,
    List<TimeSlot>? slots,
  }) {
    return TutorProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      subjectsList: subjectsList ?? this.subjectsList,
      languages: languages ?? this.languages,
      teachingMode: teachingMode ?? this.teachingMode,
      experienceYears: experienceYears ?? this.experienceYears,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      avatarUrl: avatarUrl == kUnset ? this.avatarUrl : avatarUrl as String?,
      avatarPublicId: avatarPublicId ?? this.avatarPublicId,
      updatedAt:
          updatedAt == kUnset ? this.updatedAt : updatedAt as DateTime?,
      slots: slots ?? this.slots,
    );
  }
}
