import '../core/utils/firestore_value.dart';

class Review {
  const Review({
    required this.bookingId,
    required this.studentId,
    required this.studentName,
    required this.tutorId,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      bookingId: stringFrom(map['bookingId'], id),
      studentId: stringFrom(map['studentId']),
      studentName: stringFrom(map['studentName']),
      tutorId: stringFrom(map['tutorId']),
      stars: intFrom(map['stars']),
      comment: stringFrom(map['comment']),
      createdAt: dateTimeFromFirestore(map['createdAt']) ?? DateTime.now(),
    );
  }

  final String bookingId;
  final String studentId;
  final String studentName;
  final String tutorId;
  final int stars;
  final String comment;
  final DateTime createdAt;

  bool get hasComment => comment.trim().isNotEmpty;

  String get starsLabel => '$stars/5';

  Map<String, dynamic> toMap() => <String, dynamic>{
    'bookingId': bookingId,
    'studentId': studentId,
    'studentName': studentName,
    'tutorId': tutorId,
    'stars': stars,
    'comment': comment,
    'createdAt': dateTimeToFirestore(createdAt),
  };
}
