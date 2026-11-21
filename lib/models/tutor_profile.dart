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

class TutorProfile {
  const TutorProfile({
    required this.uid,
    required this.displayName,
    required this.subjects,
    required this.hourlyRate,
    required this.rating,
    required this.ratingCount,
    required this.bio,
    required this.meetingRoomInfo,
    required this.verificationStatus,
    required this.credentialUrls,
    required this.slots,
    this.avatarUrl,
  });

  factory TutorProfile.fromMap(Map<String, dynamic> map) {
    return TutorProfile(
      uid: stringFrom(map['uid']),
      displayName: stringFrom(map['displayName']),
      subjects: stringListFrom(map['subjects']),
      hourlyRate: doubleFrom(map['hourlyRate']),
      rating: doubleFrom(map['rating']),
      ratingCount: intFrom(map['ratingCount']),
      bio: stringFrom(map['bio']),
      meetingRoomInfo: stringFrom(map['meetingRoomInfo']),
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
      credentialUrls: stringListFrom(map['credentialUrls']),
      slots: mapListFrom(map['slots'])
          .map((Map<String, dynamic> item) => TimeSlot.fromMap(item))
          .toList(growable: true),
    );
  }

  final String uid;
  final String displayName;
  final List<String> subjects;
  final double hourlyRate;
  final double rating;
  final int ratingCount;
  final String bio;
  final String meetingRoomInfo;
  final VerificationStatus verificationStatus;
  final String? avatarUrl;
  final List<String> credentialUrls;
  final List<TimeSlot> slots;

  String get initials {
    final List<String> parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'uid': uid,
    'displayName': displayName,
    'subjects': subjects,
    'hourlyRate': hourlyRate,
    'rating': rating,
    'ratingCount': ratingCount,
    'bio': bio,
    'meetingRoomInfo': meetingRoomInfo,
    'verificationStatus': verificationStatus.value,
    'avatarUrl': avatarUrl,
    'credentialUrls': credentialUrls,
    'slots': slots.map((TimeSlot slot) => slot.toMap()).toList(growable: false),
  };

  TutorProfile copyWith({
    String? uid,
    String? displayName,
    List<String>? subjects,
    double? hourlyRate,
    double? rating,
    int? ratingCount,
    String? bio,
    String? meetingRoomInfo,
    VerificationStatus? verificationStatus,
    Object? avatarUrl = kUnset,
    List<String>? credentialUrls,
    List<TimeSlot>? slots,
  }) {
    return TutorProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      subjects: subjects ?? this.subjects,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      bio: bio ?? this.bio,
      meetingRoomInfo: meetingRoomInfo ?? this.meetingRoomInfo,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      avatarUrl: avatarUrl == kUnset ? this.avatarUrl : avatarUrl as String?,
      credentialUrls: credentialUrls ?? this.credentialUrls,
      slots: slots ?? this.slots,
    );
  }
}
