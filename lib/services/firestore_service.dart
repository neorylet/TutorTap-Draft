import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/firestore_value.dart';
import '../models/assignment.dart';
import '../models/booking.dart';
import '../models/classroom_module.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/flashcard_deck.dart';
import '../models/mock_exam.dart';
import '../models/time_slot.dart';
import '../models/tutor_private_profile.dart';
import '../models/tutor_profile.dart';

class SlotAlreadyTakenException implements Exception {
  const SlotAlreadyTakenException([
    this.message = 'That slot was just taken. Please choose another one.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class TutorPage {
  const TutorPage({required this.tutors, required this.lastDocument});

  final List<TutorProfile> tutors;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _dumpSlots(List<TimeSlot> slots) => slots
      .map(
        (TimeSlot s) =>
            '{id:${s.id} start:${s.start.toUtc().toIso8601String()} '
            'end:${s.end.toUtc().toIso8601String()} lockedBy:${s.lockedBy} '
            'exp:${s.lockExpiresAt?.toUtc().toIso8601String()} '
            'bookedBy:${s.bookedBy} courseId:${s.courseId}}',
      )
      .join(' || ');

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get tutors =>
      _firestore.collection('tutors');
  CollectionReference<Map<String, dynamic>> get bookings =>
      _firestore.collection('bookings');
  CollectionReference<Map<String, dynamic>> get courses =>
      _firestore.collection('courses');
  CollectionReference<Map<String, dynamic>> get modules =>
      _firestore.collection('modules');
  CollectionReference<Map<String, dynamic>> get assignments =>
      _firestore.collection('assignments');
  CollectionReference<Map<String, dynamic>> get exams =>
      _firestore.collection('exams');
  CollectionReference<Map<String, dynamic>> get flashcardDecks =>
      _firestore.collection('flashcard_decks');
  CollectionReference<Map<String, dynamic>> get mockExams =>
      _firestore.collection('mock_exams');
  CollectionReference<Map<String, dynamic>> get verificationRequests =>
      _firestore.collection('verification_requests');

  Future<TutorPage> fetchVerifiedTutors({
    int limit = AppConstants.catalogPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = tutors
        .where('verificationStatus', isEqualTo: 'verified')
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    final List<TutorProfile> items = snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              TutorProfile.fromMap(<String, dynamic>{
                ...doc.data(),
                'uid': doc.id,
              }),
        )
        .toList(growable: true);
    return TutorPage(
      tutors: items,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
    );
  }

  Future<TutorProfile?> fetchTutor(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await tutors
        .doc(uid)
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return TutorProfile.fromMap(<String, dynamic>{...data, 'uid': uid});
  }

  Stream<List<TimeSlot>> watchSlots(String tutorId) {
    return tutors.doc(tutorId).snapshots().map((snapshot) {
      final Map<String, dynamic>? data = snapshot.data();
      if (data == null) return <TimeSlot>[];
      return TutorProfile.fromMap(<String, dynamic>{...data, 'uid': tutorId})
          .slots;
    });
  }

  Stream<List<Booking>> watchBookingsForStudent(String studentId) {
    return bookings
        .where('studentId', isEqualTo: studentId)
        .orderBy('slotStart', descending: true)
        .snapshots()
        .map(_bookingsFromSnapshot);
  }

  Stream<List<Booking>> watchBookingsForTutor(String tutorId) {
    return bookings
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('status')
        .snapshots()
        .map(_bookingsFromSnapshot);
  }

  Stream<List<ClassroomModule>> watchModules(String tutorId) {
    return modules
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    ClassroomModule.fromMap(<String, dynamic>{
                      ...doc.data(),
                      'id': doc.id,
                    }),
              )
              .toList(growable: true),
        );
  }

  Stream<List<Assignment>> watchAssignmentsForStudent(String studentId) {
    return assignments
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(_assignmentsFromSnapshot);
  }

  Stream<List<Assignment>> watchAssignmentsForTutor(String tutorId) {
    return assignments
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map(_assignmentsFromSnapshot);
  }

  Stream<List<Course>> watchCoursesForTutor(String tutorId) {
    return courses
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    Course.fromMap(<String, dynamic>{
                      ...doc.data(),
                      'id': doc.id,
                    }),
              )
              .toList(growable: true),
        );
  }

  Future<Course> createCourse({
    required String tutorId,
    required String title,
    required String description,
    required String subject,
  }) async {
    final DateTime now = DateTime.now();
    final DocumentReference<Map<String, dynamic>> ref = courses.doc();
    final Course course = Course(
      id: ref.id,
      tutorId: tutorId,
      title: title,
      description: description,
      subject: subject,
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(course.toMap());
    return course;
  }

  Future<void> deleteModule(String moduleId) async {
    await modules.doc(moduleId).delete();
  }

  Future<void> updateModule(String moduleId, Map<String, dynamic> data) async {
    await modules.doc(moduleId).update(data);
  }

  Future<void> deleteCourse(String courseId) async {
    final WriteBatch batch = _firestore.batch();

    final QuerySnapshot<Map<String, dynamic>> modulesSnapshot = await modules
        .where('courseId', isEqualTo: courseId)
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in modulesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(courses.doc(courseId));

    await batch.commit();
  }

  Future<void> deleteExam(String examId) async {
    // TODO: Clean up Cloudinary files if exam has attachments (future feature)
    await exams.doc(examId).delete();
  }

  Future<void> deleteAssignment(String assignmentId) async {
    // TODO: Clean up Cloudinary files if assignment has attachments
    await assignments.doc(assignmentId).delete();
  }

  Stream<List<Exam>> watchExams(String tutorId) {
    return exams
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    Exam.fromMap(<String, dynamic>{
                      ...doc.data(),
                      'id': doc.id,
                    }),
              )
              .toList(growable: true),
        );
  }

  Stream<List<FlashcardDeck>> watchDecks(String ownerId) {
    return flashcardDecks
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    FlashcardDeck.fromMap(<String, dynamic>{
                      ...doc.data(),
                      'id': doc.id,
                    }),
              )
              .toList(growable: true),
        );
  }

  Stream<List<MockExam>> watchMockExams(String ownerId) {
    return mockExams
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    MockExam.fromMap(<String, dynamic>{
                      ...doc.data(),
                      'id': doc.id,
                    }),
              )
              .toList(growable: true),
        );
  }

  Future<void> saveTutorProfile(TutorProfile profile) {
    final Map<String, dynamic> data = <String, dynamic>{
      ...profile.toMap(),
      'meetingRoomInfo': FieldValue.delete(),
      'credentialUrls': FieldValue.delete(),
    };
    return tutors.doc(profile.uid).set(data, SetOptions(merge: true));
  }

  Future<TutorPrivateProfile?> fetchTutorPrivate(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('tutor_private')
        .doc(uid)
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return TutorPrivateProfile.fromMap(<String, dynamic>{...data, 'uid': uid});
  }

  Future<void> saveTutorPrivateProfile(TutorPrivateProfile profile) {
    return _firestore
        .collection('tutor_private')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<DocumentReference<Map<String, dynamic>>> addModule(
    ClassroomModule module,
  ) {
    final DocumentReference<Map<String, dynamic>> ref = modules.doc(
      module.id.isEmpty ? null : module.id,
    );
    return ref.set(module.copyWith(id: ref.id).toMap()).then((_) => ref);
  }

  Future<DocumentReference<Map<String, dynamic>>> addAssignment(
    Assignment assignment,
  ) {
    final DocumentReference<Map<String, dynamic>> ref = assignments.doc(
      assignment.id.isEmpty ? null : assignment.id,
    );
    return ref.set(assignment.copyWith(id: ref.id).toMap()).then((_) => ref);
  }

  Future<DocumentReference<Map<String, dynamic>>> addExam(Exam exam) {
    final DocumentReference<Map<String, dynamic>> ref = exams.doc(
      exam.id.isEmpty ? null : exam.id,
    );
    return ref.set(exam.copyWith(id: ref.id).toMap()).then((_) => ref);
  }

  Future<DocumentReference<Map<String, dynamic>>> addDeck(FlashcardDeck deck) {
    final DocumentReference<Map<String, dynamic>> ref = flashcardDecks.doc(
      deck.id.isEmpty ? null : deck.id,
    );
    return ref.set(deck.copyWith(id: ref.id).toMap()).then((_) => ref);
  }

  Future<DocumentReference<Map<String, dynamic>>> addMockExam(
    MockExam mockExam,
  ) {
    final DocumentReference<Map<String, dynamic>> ref = mockExams.doc(
      mockExam.id.isEmpty ? null : mockExam.id,
    );
    return ref.set(mockExam.copyWith(id: ref.id).toMap()).then((_) => ref);
  }

  Future<void> updateAssignment(
    String assignmentId,
    Map<String, dynamic> changes,
  ) {
    return assignments.doc(assignmentId).update(changes);
  }

  Future<void> updateExam(String examId, Map<String, dynamic> changes) {
    return exams.doc(examId).update(changes);
  }

  Future<void> updateDeck(String deckId, FlashcardDeck deck) {
    return flashcardDecks.doc(deckId).set(deck.toMap());
  }

  Future<void> updateMockExam(String mockId, MockExam exam) {
    return mockExams.doc(mockId).set(exam.toMap());
  }



  Future<Booking> confirmSimulatedBooking({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String studentName,
    required String tutorName,
    required String subject,
    required DateTime slotStart,
    required DateTime slotEnd,
    required OnlineSession onlineSession,
    required double subtotal,
    double commissionRate = AppConstants.defaultCommissionRate,
  }) async {
    final DocumentReference<Map<String, dynamic>> bookingRef = bookings.doc();
    final DocumentReference<Map<String, dynamic>> tutorRef = tutors.doc(
      tutorId,
    );
    final DateTime now = DateTime.now();
    final CommissionBreakdown money = AppConstants.calculateCommission(
      subtotal,
      commissionRate,
    );

    final Booking booking = Booking(
      id: bookingRef.id,
      studentId: studentId,
      tutorId: tutorId,
      tutorName: tutorName,
      studentName: studentName,
      subject: subject,
      slotStart: slotStart,
      slotEnd: slotEnd,
      status: BookingStatus.confirmed,
      onlineSession: onlineSession,
      subtotal: money.subtotal,
      commissionRate: money.commissionRate,
      commissionAmount: money.commissionAmount,
      totalCharged: money.totalCharged,
      tutorPayout: money.tutorPayout,
      paymentMode: AppConstants.paymentMode,
      createdAt: now,
    );
    debugPrint(
      '[BOOKING_RECON] booking keys=${booking.toMap().keys.join(",")}',
    );

    debugPrint(
      '[BOOKING_RECON] confirmSimulatedBooking start tutor=$tutorId slot=$slotId '
      'studentId=$studentId authUid=${FirebaseAuth.instance.currentUser?.uid}',
    );
    try {
      await _firestore.runTransaction<void>((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> tutorSnapshot =
            await transaction.get(tutorRef);
        final Map<String, dynamic>? tutorData = tutorSnapshot.data();
        if (!tutorSnapshot.exists || tutorData == null) {
          throw const SlotAlreadyTakenException(
            'Tutor is no longer available.',
          );
        }
        final TutorProfile profile = TutorProfile.fromMap(<String, dynamic>{
          ...tutorData,
          'uid': tutorId,
        });
        debugPrint(
          '[BOOKING_RECON] server slots BEFORE = ${_dumpSlots(profile.slots)}',
        );
        final int index = profile.slots.indexWhere(
          (TimeSlot slot) => slot.id == slotId,
        );
        if (index < 0) {
          throw const SlotAlreadyTakenException('That slot no longer exists.');
        }
        final TimeSlot slot = profile.slots[index];
        if (slot.bookedBy != null || !slot.start.isAfter(now)) {
          throw const SlotAlreadyTakenException('That slot was just taken.');
        }

        final List<TimeSlot> updatedSlots = List<TimeSlot>.from(profile.slots);
        updatedSlots[index] = slot.copyWith(bookedBy: studentId);
        debugPrint(
          '[BOOKING_RECON] client slots AFTER  = ${_dumpSlots(updatedSlots)}',
        );
        transaction.update(tutorRef, <String, dynamic>{
          'slots': updatedSlots
              .map((TimeSlot item) => item.toMap())
              .toList(growable: false),
        });
        transaction.set(bookingRef, booking.toMap());
      });
    } on Object catch (e, st) {
      debugPrint(
        '[BOOKING_RECON] confirmSimulatedBooking FAILED type=${e.runtimeType} '
        'firebase=${e is FirebaseException ? "${e.plugin}/${e.code}/${e.message}" : "n/a"}',
      );
      debugPrint('[BOOKING_RECON] stack=$st');
      rethrow;
    }

    return booking;
  }

  Future<void> cancelBooking(
    Booking booking, {
    required String cancelledBy,
    required String reason,
    String note = '',
  }) async {
    final DocumentReference<Map<String, dynamic>> bookingRef = bookings.doc(
      booking.id,
    );
    final DocumentReference<Map<String, dynamic>> tutorRef = tutors.doc(
      booking.tutorId,
    );

    await _firestore.runTransaction<void>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> tutorSnapshot =
          await transaction.get(tutorRef);
      final Map<String, dynamic>? tutorData = tutorSnapshot.data();

      if (tutorData != null) {
        final TutorProfile profile = TutorProfile.fromMap(<String, dynamic>{
          ...tutorData,
          'uid': booking.tutorId,
        });
        final int index = profile.slots.indexWhere(
          (TimeSlot slot) =>
              slot.bookedBy == booking.studentId &&
              slot.start.isAtSameMomentAs(booking.slotStart),
        );
        if (index >= 0) {
          final List<TimeSlot> updatedSlots = List<TimeSlot>.from(
            profile.slots,
          );
          updatedSlots[index] = updatedSlots[index].copyWith(
            bookedBy: null,
            lockedBy: null,
            lockExpiresAt: null,
          );
          transaction.update(tutorRef, <String, dynamic>{
            'slots': updatedSlots
                .map((TimeSlot slot) => slot.toMap())
                .toList(growable: false),
          });
        }
      }

      transaction.update(bookingRef, <String, dynamic>{
        'status': BookingStatus.cancelled.value,
        'cancelledBy': cancelledBy,
        'cancellationReason': reason,
        'cancellationNote': note,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> completeBooking(Booking booking) {
    return bookings.doc(booking.id).update(<String, dynamic>{
      'status': BookingStatus.completed.value,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rescheduleBooking({
    required Booking booking,
    required String newSlotId,
    required DateTime newStart,
    required DateTime newEnd,
    required String reason,
    required String note,
  }) async {
    final DocumentReference<Map<String, dynamic>> bookingRef = bookings.doc(
      booking.id,
    );
    final DocumentReference<Map<String, dynamic>> tutorRef = tutors.doc(
      booking.tutorId,
    );

    await _firestore.runTransaction<void>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> tutorSnapshot =
          await transaction.get(tutorRef);
      final Map<String, dynamic>? tutorData = tutorSnapshot.data();
      if (!tutorSnapshot.exists || tutorData == null) {
        throw const SlotAlreadyTakenException('Tutor is no longer available.');
      }
      final TutorProfile profile = TutorProfile.fromMap(<String, dynamic>{
        ...tutorData,
        'uid': booking.tutorId,
      });
      final List<TimeSlot> updatedSlots = List<TimeSlot>.from(profile.slots);
      final int newIndex = updatedSlots.indexWhere(
        (TimeSlot slot) => slot.id == newSlotId,
      );
      if (newIndex < 0) {
        throw const SlotAlreadyTakenException('That slot no longer exists.');
      }
      final TimeSlot newSlot = updatedSlots[newIndex];
      final DateTime now = DateTime.now();
      if (newSlot.bookedBy != null || !newSlot.start.isAfter(now)) {
        throw const SlotAlreadyTakenException('That slot was just taken.');
      }

      final int oldIndex = updatedSlots.indexWhere(
        (TimeSlot slot) =>
            slot.bookedBy == booking.studentId &&
            slot.start.isAtSameMomentAs(booking.slotStart),
      );
      if (oldIndex >= 0) {
        updatedSlots[oldIndex] = updatedSlots[oldIndex].copyWith(
          bookedBy: null,
          lockedBy: null,
          lockExpiresAt: null,
        );
      }
      updatedSlots[newIndex] = newSlot.copyWith(
        lockedBy: null,
        lockExpiresAt: null,
        bookedBy: booking.studentId,
      );

      transaction.update(tutorRef, <String, dynamic>{
        'slots': updatedSlots
            .map((TimeSlot item) => item.toMap())
            .toList(growable: false),
      });
      transaction.update(bookingRef, <String, dynamic>{
        'slotStart': dateTimeToFirestore(newStart),
        'slotEnd': dateTimeToFirestore(newEnd),
        'status': BookingStatus.confirmed.value,
        'rescheduleReason': reason,
        'rescheduleNote': note,
        'rescheduledAt': FieldValue.serverTimestamp(),
        'previousSlotStart': Timestamp.fromDate(booking.slotStart),
      });
    });
  }

  Future<void> requestTutorVerification(
    TutorProfile profile,
    String recipientEmail,
  ) {
    return verificationRequests.doc(profile.uid).set(<String, dynamic>{
      'uid': profile.uid,
      'displayName': profile.displayName,
      'recipientEmail': recipientEmail,
      'subjects': profile.subjectsList,
      'languages': profile.languages,
      'headline': profile.headline,
      'hourlyRate': profile.hourlyRate,
      'bio': profile.bio,
      'status': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  List<Booking> _bookingsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Booking.fromMap(<String, dynamic>{...doc.data(), 'id': doc.id}),
        )
        .toList(growable: true);
  }

  List<Assignment> _assignmentsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Assignment.fromMap(<String, dynamic>{
                ...doc.data(),
                'id': doc.id,
              }),
        )
        .toList(growable: true);
  }
}
