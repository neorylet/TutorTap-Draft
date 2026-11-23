import '../core/constants/app_constants.dart';
import '../core/utils/firestore_value.dart';

class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.start,
    required this.end,
    this.lockedBy,
    this.lockExpiresAt,
    this.bookedBy,
    this.courseId,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: stringFrom(map['id']),
      start: dateTimeFromFirestore(map['start']) ?? DateTime.now(),
      end: dateTimeFromFirestore(map['end']) ?? DateTime.now(),
      lockedBy: map['lockedBy'] as String?,
      lockExpiresAt: dateTimeFromFirestore(map['lockExpiresAt']),
      bookedBy: map['bookedBy'] as String?,
      courseId: map['courseId'] as String?,
    );
  }

  final String id;
  final DateTime start;
  final DateTime end;
  final String? lockedBy;
  final DateTime? lockExpiresAt;
  final String? bookedBy;
  final String? courseId;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'start': dateTimeToFirestore(start),
    'end': dateTimeToFirestore(end),
    'lockedBy': lockedBy,
    'lockExpiresAt': dateTimeToFirestore(lockExpiresAt),
    'bookedBy': bookedBy,
    'courseId': courseId,
  };

  TimeSlot copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    Object? lockedBy = kUnset,
    Object? lockExpiresAt = kUnset,
    Object? bookedBy = kUnset,
    Object? courseId = kUnset,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      lockedBy: lockedBy == kUnset ? this.lockedBy : lockedBy as String?,
      lockExpiresAt: lockExpiresAt == kUnset
          ? this.lockExpiresAt
          : dateTimeFromFirestore(lockExpiresAt),
      bookedBy: bookedBy == kUnset ? this.bookedBy : bookedBy as String?,
      courseId: courseId == kUnset ? this.courseId : courseId as String?,
    );
  }

  bool get isBooked => bookedBy != null && bookedBy!.isNotEmpty;

  bool isLocked(DateTime now) {
    if (isBooked) return false;
    if (lockedBy == null || lockedBy!.isEmpty) return false;
    final DateTime? expiry = lockExpiresAt;
    if (expiry == null) return false;
    return expiry.isAfter(now);
  }

  bool isLockedBy(String uid, DateTime now) => isLocked(now) && lockedBy == uid;

  bool isAvailable(DateTime now) => !isBooked && !isLocked(now);

  Duration remainingLockTime(DateTime now) {
    final DateTime? expiry = lockExpiresAt;
    if (!isLocked(now) || expiry == null) return Duration.zero;
    final Duration remaining = expiry.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  TimeSlot lock(String uid, DateTime now) => copyWith(
    lockedBy: uid,
    lockExpiresAt: now.add(AppConstants.slotLockDuration),
  );
}
