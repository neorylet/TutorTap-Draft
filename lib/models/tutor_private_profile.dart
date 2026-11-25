import '../core/utils/firestore_value.dart';

class TutorPrivateProfile {
  const TutorPrivateProfile({
    required this.uid,
    required this.meetingRoomInfo,
    required this.contactEmail,
    this.credentialUrls = const <String>[],
  });

  factory TutorPrivateProfile.fromMap(Map<String, dynamic> map) {
    return TutorPrivateProfile(
      uid: stringFrom(map['uid']),
      meetingRoomInfo: stringFrom(map['meetingRoomInfo']),
      contactEmail: stringFrom(map['contactEmail']),
      credentialUrls: stringListFrom(map['credentialUrls']),
    );
  }

  final String uid;
  final String meetingRoomInfo;
  final String contactEmail;
  // Kept unused for when identity review lands later.
  final List<String> credentialUrls;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'uid': uid,
    'meetingRoomInfo': meetingRoomInfo,
    'contactEmail': contactEmail,
    'credentialUrls': credentialUrls,
  };

  TutorPrivateProfile copyWith({
    String? uid,
    String? meetingRoomInfo,
    String? contactEmail,
    List<String>? credentialUrls,
  }) {
    return TutorPrivateProfile(
      uid: uid ?? this.uid,
      meetingRoomInfo: meetingRoomInfo ?? this.meetingRoomInfo,
      contactEmail: contactEmail ?? this.contactEmail,
      credentialUrls: credentialUrls ?? this.credentialUrls,
    );
  }
}
