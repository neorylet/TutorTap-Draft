import '../core/constants/app_constants.dart';
import '../core/utils/firestore_value.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get value => switch (this) {
    BookingStatus.pending => 'pending',
    BookingStatus.confirmed => 'confirmed',
    BookingStatus.completed => 'completed',
    BookingStatus.cancelled => 'cancelled',
  };
}

class OnlineSession {
  const OnlineSession({this.link = '', this.room = '', this.note = ''});

  factory OnlineSession.fromMap(Map<String, dynamic> map) {
    return OnlineSession(
      link: stringFrom(map['link']),
      room: stringFrom(map['room']),
      note: stringFrom(map['note']),
    );
  }

  final String link;
  final String room;
  final String note;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'link': link,
    'room': room,
    'note': note,
  };

  OnlineSession copyWith({String? link, String? room, String? note}) {
    return OnlineSession(
      link: link ?? this.link,
      room: room ?? this.room,
      note: note ?? this.note,
    );
  }

  String get displayValue => link.isNotEmpty ? link : room;
}

class Booking {
  const Booking({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.tutorName,
    required this.studentName,
    required this.subject,
    required this.slotStart,
    required this.slotEnd,
    required this.status,
    required this.onlineSession,
    required this.subtotal,
    required this.commissionRate,
    required this.commissionAmount,
    required this.totalCharged,
    required this.tutorPayout,
    required this.paymentMode,
    required this.createdAt,
    this.courseId,
    this.completedAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: stringFrom(map['id']),
      studentId: stringFrom(map['studentId']),
      tutorId: stringFrom(map['tutorId']),
      tutorName: stringFrom(map['tutorName']),
      studentName: stringFrom(map['studentName']),
      subject: stringFrom(map['subject']),
      slotStart: dateTimeFromFirestore(map['slotStart']) ?? DateTime.now(),
      slotEnd: dateTimeFromFirestore(map['slotEnd']) ?? DateTime.now(),
      status: enumFrom<BookingStatus>(map['status'], <String, BookingStatus>{
        'pending': BookingStatus.pending,
        'confirmed': BookingStatus.confirmed,
        'completed': BookingStatus.completed,
        'cancelled': BookingStatus.cancelled,
      }, BookingStatus.pending),
      onlineSession: OnlineSession.fromMap(mapFrom(map['onlineSession'])),
      subtotal: doubleFrom(map['subtotal']),
      commissionRate: doubleFrom(
        map['commissionRate'],
        AppConstants.defaultCommissionRate,
      ),
      commissionAmount: doubleFrom(map['commissionAmount']),
      totalCharged: doubleFrom(map['totalCharged']),
      tutorPayout: doubleFrom(map['tutorPayout']),
      paymentMode: stringFrom(map['paymentMode'], AppConstants.paymentMode),
      createdAt: dateTimeFromFirestore(map['createdAt']) ?? DateTime.now(),
      courseId: map['courseId'] == null ? null : stringFrom(map['courseId']),
      completedAt: dateTimeFromFirestore(map['completedAt']),
    );
  }

  final String id;
  final String studentId;
  final String tutorId;
  final String tutorName;
  final String studentName;
  final String subject;
  final DateTime slotStart;
  final DateTime slotEnd;
  final BookingStatus status;
  final OnlineSession onlineSession;
  final double subtotal;
  final double commissionRate;
  final double commissionAmount;
  final double totalCharged;
  final double tutorPayout;
  final String paymentMode;
  final DateTime createdAt;
  final String? courseId;
  final DateTime? completedAt;

  bool get isPast => slotEnd.isBefore(DateTime.now());
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isUpcoming => !isPast && !isCompleted && !isCancelled;
  bool get canBeCompleted => status == BookingStatus.confirmed && isPast;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'studentId': studentId,
    'tutorId': tutorId,
    'tutorName': tutorName,
    'studentName': studentName,
    'subject': subject,
    'slotStart': dateTimeToFirestore(slotStart),
    'slotEnd': dateTimeToFirestore(slotEnd),
    'status': status.value,
    'onlineSession': onlineSession.toMap(),
    'subtotal': subtotal,
    'commissionRate': commissionRate,
    'commissionAmount': commissionAmount,
    'totalCharged': totalCharged,
    'tutorPayout': tutorPayout,
    'paymentMode': paymentMode,
    'createdAt': dateTimeToFirestore(createdAt),
    'courseId': courseId,
    'completedAt': dateTimeToFirestore(completedAt),
  };

  Booking copyWith({
    String? id,
    String? studentId,
    String? tutorId,
    String? tutorName,
    String? studentName,
    String? subject,
    DateTime? slotStart,
    DateTime? slotEnd,
    BookingStatus? status,
    OnlineSession? onlineSession,
    double? subtotal,
    double? commissionRate,
    double? commissionAmount,
    double? totalCharged,
    double? tutorPayout,
    String? paymentMode,
    DateTime? createdAt,
    Object? courseId = kUnset,
    Object? completedAt = kUnset,
  }) {
    return Booking(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      tutorName: tutorName ?? this.tutorName,
      studentName: studentName ?? this.studentName,
      subject: subject ?? this.subject,
      slotStart: slotStart ?? this.slotStart,
      slotEnd: slotEnd ?? this.slotEnd,
      status: status ?? this.status,
      onlineSession: onlineSession ?? this.onlineSession,
      subtotal: subtotal ?? this.subtotal,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      totalCharged: totalCharged ?? this.totalCharged,
      tutorPayout: tutorPayout ?? this.tutorPayout,
      paymentMode: paymentMode ?? this.paymentMode,
      createdAt: createdAt ?? this.createdAt,
      courseId: courseId == kUnset ? this.courseId : courseId as String?,
      completedAt: completedAt == kUnset
          ? this.completedAt
          : dateTimeFromFirestore(completedAt),
    );
  }
}
