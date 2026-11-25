import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/booking.dart';
import '../models/classroom_module.dart';
import '../models/exam.dart';
import '../models/flashcard_deck.dart';
import '../models/mock_exam.dart';
import '../models/module_file.dart';
import '../models/question.dart';
import '../models/time_slot.dart';
import '../models/tutor_private_profile.dart';
import '../models/tutor_profile.dart';

class SeedService {
  SeedService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String demoStudentId = 'demo-student';

  Future<void> seedAll() async {
    final WriteBatch batch = _firestore.batch();
    final DateTime now = DateTime.now();

    batch.set(
      _firestore.collection('users').doc(demoStudentId),
      AppUser(
        uid: demoStudentId,
        email: 'student@tutortap.app',
        displayName: 'Mika Santos',
        role: UserRole.student,
        createdAt: now,
      ).toMap(),
    );

    for (final TutorProfile tutor in _sampleTutors(now)) {
      batch.set(
        _firestore.collection('users').doc(tutor.uid),
        _tutorUser(tutor, now).toMap(),
      );
      batch.set(_firestore.collection('tutors').doc(tutor.uid), tutor.toMap());
      batch.set(
        _firestore.collection('tutor_private').doc(tutor.uid),
        TutorPrivateProfile(
          uid: tutor.uid,
          meetingRoomInfo: 'meet.tutortap.app/${tutor.uid}-room',
          contactEmail: '${tutor.uid}@tutortap.app',
        ).toMap(),
      );
    }

    for (final Booking booking in _sampleBookings(now)) {
      batch.set(
        _firestore.collection('bookings').doc(booking.id),
        booking.toMap(),
      );
    }
    for (final ClassroomModule module in _sampleModules(now)) {
      batch.set(
        _firestore.collection('modules').doc(module.id),
        module.toMap(),
      );
    }
    for (final Assignment assignment in _sampleAssignments(now)) {
      batch.set(
        _firestore.collection('assignments').doc(assignment.id),
        assignment.toMap(),
      );
    }
    for (final Exam exam in _sampleExams(now)) {
      batch.set(_firestore.collection('exams').doc(exam.id), exam.toMap());
    }
    for (final FlashcardDeck deck in _sampleDecks()) {
      batch.set(
        _firestore.collection('flashcard_decks').doc(deck.id),
        deck.toMap(),
      );
    }
    for (final MockExam exam in _sampleMockExams()) {
      batch.set(_firestore.collection('mock_exams').doc(exam.id), exam.toMap());
    }

    await batch.commit();
  }

  AppUser _tutorUser(TutorProfile tutor, DateTime now) {
    return AppUser(
      uid: tutor.uid,
      email: '${tutor.uid}@tutortap.app',
      displayName: tutor.displayName,
      role: UserRole.tutor,
      createdAt: now,
    );
  }

  List<TutorProfile> _sampleTutors(DateTime now) {
    return <TutorProfile>[
      _tutor(
        uid: 'ana',
        name: 'Ana Reyes',
        headline: 'Patient math tutor for algebra and calculus',
        subjects: const <String>['Math'],
        languages: const <String>['English', 'Filipino'],
        teachingMode: 'online',
        experienceYears: 5,
        experience: const <TutorExperience>[
          TutorExperience(
            role: 'Math Tutor',
            organization: 'TutorTap',
            startYear: 2021,
            endYear: 2026,
            description: 'Guided students through algebra, calculus, and exam prep.',
          ),
        ],
        education: const <TutorEducation>[
          TutorEducation(school: 'UP Diliman', degree: 'BS Mathematics', year: 2020),
        ],
        certifications: const <TutorCertification>[
          TutorCertification(name: 'TESOL', issuer: 'TESOL Intl', year: 2022),
        ],
        rate: 450,
        rating: 4.9,
        reviews: 128,
        bio: 'Patient math tutor who makes algebra and calculus feel simple.',
        now: now,
      ),
      _tutor(
        uid: 'ben',
        name: 'Ben Castillo',
        headline: 'CS mentor for algorithms and projects',
        subjects: const <String>['Computer Science'],
        languages: const <String>['English'],
        teachingMode: 'both',
        experienceYears: 4,
        experience: const <TutorExperience>[
          TutorExperience(
            role: 'Software Mentor',
            organization: 'Code Lab',
            startYear: 2022,
            endYear: 2026,
            description: 'Mentored students in data structures and project work.',
          ),
        ],
        education: const <TutorEducation>[
          TutorEducation(school: 'DLSU', degree: 'BS Computer Science', year: 2021),
        ],
        certifications: const <TutorCertification>[],
        rate: 600,
        rating: 4.8,
        reviews: 96,
        bio: 'CS mentor focused on data structures, algorithms and projects.',
        now: now,
      ),
      _tutor(
        uid: 'carla',
        name: 'Carla Dizon',
        headline: 'English coach for writing and speaking',
        subjects: const <String>['English'],
        languages: const <String>['English', 'Filipino'],
        teachingMode: 'online',
        experienceYears: 6,
        experience: const <TutorExperience>[
          TutorExperience(
            role: 'English Tutor',
            organization: 'Freelance',
            startYear: 2020,
            endYear: 2026,
            description: 'Helped learners improve grammar, essays, and confidence.',
          ),
        ],
        education: const <TutorEducation>[
          TutorEducation(school: 'Ateneo de Manila', degree: 'BA English', year: 2019),
        ],
        certifications: const <TutorCertification>[],
        rate: 380,
        rating: 4.7,
        reviews: 74,
        bio: 'English tutor for grammar, essays and confident speaking.',
        now: now,
      ),
      _tutor(
        uid: 'daniel',
        name: 'Daniel Ocampo',
        headline: 'Math and CS exam prep specialist',
        subjects: const <String>['Math', 'Computer Science'],
        languages: const <String>['English'],
        teachingMode: 'online',
        experienceYears: 3,
        experience: const <TutorExperience>[
          TutorExperience(
            role: 'Tutor',
            organization: 'TutorTap',
            startYear: 2023,
            endYear: 2026,
            description: 'Focused on problem solving and exam preparation.',
          ),
        ],
        education: const <TutorEducation>[
          TutorEducation(school: 'UST', degree: 'BS Applied Math', year: 2022),
        ],
        certifications: const <TutorCertification>[],
        rate: 520,
        rating: 4.6,
        reviews: 63,
        bio: 'Math and CS tutor who loves exam prep and problem solving.',
        now: now,
      ),
      _tutor(
        uid: 'elise',
        name: 'Elise Tan',
        headline: 'Gentle guide for reading and literature',
        subjects: const <String>['English'],
        languages: const <String>['English', 'Mandarin'],
        teachingMode: 'in-person',
        experienceYears: 7,
        experience: const <TutorExperience>[
          TutorExperience(
            role: 'Literature Tutor',
            organization: 'Learning Center',
            startYear: 2019,
            endYear: 2026,
            description: 'Supported students in reading comprehension and writing.',
          ),
        ],
        education: const <TutorEducation>[
          TutorEducation(school: 'UP Baguio', degree: 'BA Communication', year: 2018),
        ],
        certifications: const <TutorCertification>[],
        rate: 420,
        rating: 4.9,
        reviews: 112,
        bio: 'Reading, writing and literature tutor with a gentle approach.',
        now: now,
      ),
      _tutor(
        uid: 'francis',
        name: 'Francis Lim',
        headline: 'Programming fundamentals, made practical',
        subjects: const <String>['Computer Science'],
        languages: const <String>['English', 'Filipino'],
        teachingMode: 'both',
        experienceYears: 5,
        experience: const <TutorExperience>[
          TutorExperience(
            role: 'Full-stack Developer',
            organization: 'Tech Studio',
            startYear: 2021,
            endYear: 2026,
            description: 'Teaches programming fundamentals with real examples.',
          ),
        ],
        education: const <TutorEducation>[
          TutorEducation(school: 'Mapua', degree: 'BS Computer Engineering', year: 2020),
        ],
        certifications: const <TutorCertification>[],
        rate: 550,
        rating: 4.5,
        reviews: 58,
        bio: 'Full-stack developer teaching programming fundamentals.',
        now: now,
      ),
    ];
  }

  TutorProfile _tutor({
    required String uid,
    required String name,
    required String headline,
    required List<String> subjects,
    required List<String> languages,
    required String teachingMode,
    required int experienceYears,
    required List<TutorExperience> experience,
    required List<TutorEducation> education,
    required List<TutorCertification> certifications,
    required double rate,
    required double rating,
    required int reviews,
    required String bio,
    required DateTime now,
  }) {
    return TutorProfile(
      uid: uid,
      displayName: name,
      headline: headline,
      bio: bio,
      subjectsList: subjects,
      languages: languages,
      teachingMode: teachingMode,
      experienceYears: experienceYears,
      experience: experience,
      education: education,
      certifications: certifications,
      hourlyRate: rate,
      rating: rating,
      ratingCount: reviews,
      verificationStatus: VerificationStatus.verified,
      avatarUrl:
          'https://res.cloudinary.com/demo/image/upload/w_200,h_200,c_fill,g_face,q_auto,f_auto/tutortap/avatars/$uid.png',
      updatedAt: now,
      slots: _sampleSlots(uid, now),
    );
  }

  List<TimeSlot> _sampleSlots(String tutorId, DateTime now) {
    final List<TimeSlot> slots = <TimeSlot>[];
    for (int day = 1; day <= 3; day++) {
      for (final int hour in <int>[9, 11, 14, 16]) {
        final DateTime start = DateTime(
          now.year,
          now.month,
          now.day + day,
          hour,
        );
        TimeSlot slot = TimeSlot(
          id: '$tutorId-d$day-h$hour',
          start: start,
          end: start.add(const Duration(hours: 1)),
        );
        if (tutorId == 'ana' && day == 1 && hour == 11) {
          slot = slot.copyWith(bookedBy: demoStudentId);
        } else if (tutorId == 'ana' && day == 1 && hour == 14) {
          slot = slot.lock(demoStudentId, now);
        }
        slots.add(slot);
      }
    }
    return slots;
  }

  List<Booking> _sampleBookings(DateTime now) {
    final OnlineSession session = OnlineSession(
      link: 'meet.tutortap.app/ana-math-2014',
      room: 'Online · Math room',
      note: 'Join 5 minutes early.',
    );
    return <Booking>[
      _booking(
        id: 'b1',
        tutorId: 'ana',
        tutorName: 'Ana Reyes',
        subject: 'Math',
        rate: 450,
        status: BookingStatus.confirmed,
        dayOffset: 1,
        hour: 11,
        now: now,
        session: session,
      ),
      _booking(
        id: 'b2',
        tutorId: 'carla',
        tutorName: 'Carla Dizon',
        subject: 'English',
        rate: 380,
        status: BookingStatus.pending,
        dayOffset: 2,
        hour: 17,
        now: now,
        session: session.copyWith(link: 'meet.tutortap.app/carla-english-2014'),
      ),
      _booking(
        id: 'b3',
        tutorId: 'daniel',
        tutorName: 'Daniel Ocampo',
        subject: 'Computer Science',
        rate: 520,
        status: BookingStatus.completed,
        dayOffset: -2,
        hour: 16,
        now: now,
        session: session.copyWith(link: 'meet.tutortap.app/daniel-math-2014'),
      ),
      _booking(
        id: 'b4',
        tutorId: 'ben',
        tutorName: 'Ben Castillo',
        subject: 'Computer Science',
        rate: 600,
        status: BookingStatus.cancelled,
        dayOffset: -5,
        hour: 13,
        now: now,
        session: session.copyWith(link: 'meet.tutortap.app/ben-cs-2014'),
      ),
    ];
  }

  Booking _booking({
    required String id,
    required String tutorId,
    required String tutorName,
    required String subject,
    required double rate,
    required BookingStatus status,
    required int dayOffset,
    required int hour,
    required DateTime now,
    required OnlineSession session,
  }) {
    final DateTime start = DateTime(
      now.year,
      now.month,
      now.day + dayOffset,
      hour,
    );
    final CommissionBreakdown money = AppConstants.calculateCommission(rate);
    return Booking(
      id: id,
      studentId: demoStudentId,
      tutorId: tutorId,
      tutorName: tutorName,
      studentName: 'Mika Santos',
      subject: subject,
      slotStart: start,
      slotEnd: start.add(const Duration(hours: 1)),
      status: status,
      onlineSession: session,
      subtotal: money.subtotal,
      commissionRate: money.commissionRate,
      commissionAmount: money.commissionAmount,
      totalCharged: money.totalCharged,
      tutorPayout: money.tutorPayout,
      paymentMode: AppConstants.paymentMode,
      createdAt: now.subtract(const Duration(days: 1)),
    );
  }

  List<ClassroomModule> _sampleModules(DateTime now) {
    return <ClassroomModule>[
      ClassroomModule(
        id: 'seed-module-1',
        tutorId: 'ana',
        title: 'Algebra Basics',
        description: 'Linear equations and graphing review notes.',
        files: const <ModuleFile>[
          ModuleFile(
            url: 'https://res.cloudinary.com/demo/image/upload/sample.pdf',
            type: 'pdf',
            name: 'algebra-basics.pdf',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ClassroomModule(
        id: 'seed-module-2',
        tutorId: 'ana',
        title: 'Functions Cheat Sheet',
        description: 'One-page reference for the functions quiz.',
        files: const <ModuleFile>[
          ModuleFile(
            url: 'https://res.cloudinary.com/demo/image/upload/sample.png',
            type: 'image',
            name: 'functions-cheat-sheet.png',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Assignment> _sampleAssignments(DateTime now) {
    return <Assignment>[
      Assignment(
        id: 'hw1',
        tutorId: 'ana',
        studentId: demoStudentId,
        title: 'Homework 1: Linear Equations',
        instructions: 'Solve the 10 practice problems and upload your work.',
        dueDate: now.add(const Duration(days: 2)),
        maxScore: 10,
        status: AssignmentStatus.assigned,
      ),
      Assignment(
        id: 'hw2',
        tutorId: 'ana',
        studentId: demoStudentId,
        title: 'Graphing Functions',
        instructions: 'Graph the given functions and label the intercepts.',
        dueDate: now.subtract(const Duration(days: 2)),
        submissionText: 'Uploaded my graphing worksheet.',
        submittedAt: now.subtract(const Duration(days: 3)),
        grade: 9,
        maxScore: 10,
        feedback: 'Excellent work. Check question 4 sign carefully.',
        status: AssignmentStatus.graded,
      ),
    ];
  }

  List<Exam> _sampleExams(DateTime now) {
    final List<Question> questions = <Question>[
      const Question(
        id: 'q1',
        type: QuestionType.mcq,
        prompt: 'Which equation represents a linear function?',
        choices: <String>['y = 2x + 3', 'y = x²', 'y = 1/x', 'y = √x'],
        answerIndex: 0,
        points: 1,
      ),
      const Question(
        id: 'q2',
        type: QuestionType.mcq,
        prompt: 'What is the slope of y = 4x − 2?',
        choices: <String>['−2', '2', '4', '6'],
        answerIndex: 2,
        points: 1,
      ),
      const Question(
        id: 'q3',
        type: QuestionType.mcq,
        prompt: 'What is the derivative of x²?',
        choices: <String>['x', '2x', 'x²/2', '2'],
        answerIndex: 1,
        points: 1,
      ),
    ];
    return <Exam>[
      Exam(
        id: 'quiz1',
        tutorId: 'ana',
        title: 'Quiz 1: Functions',
        timeLimitMin: 15,
        dueDate: now.add(const Duration(days: 3)),
        questions: questions,
        attempts: const <ExamAttempt>[],
      ),
      Exam(
        id: 'midterm',
        tutorId: 'ana',
        title: 'Midterm Review',
        timeLimitMin: 30,
        dueDate: now.add(const Duration(days: 8)),
        questions: questions,
        attempts: <ExamAttempt>[
          ExamAttempt(
            studentId: demoStudentId,
            score: 8,
            at: now.subtract(const Duration(days: 4)),
          ),
        ],
      ),
    ];
  }

  List<FlashcardDeck> _sampleDecks() {
    return <FlashcardDeck>[
      FlashcardDeck(
        id: 'limits',
        ownerId: demoStudentId,
        title: 'Calculus Limits',
        subject: 'Math',
        cards: _cards(<List<String>>[
          <String>['What is a limit?', 'The value a function approaches.'],
          <String>['Derivative of x²?', '2x'],
          <String>['Limit of 1/x as x → ∞?', '0'],
        ]),
      ),
      FlashcardDeck(
        id: 'structures',
        ownerId: demoStudentId,
        title: 'Data Structures',
        subject: 'Computer Science',
        cards: _cards(<List<String>>[
          <String>['Stack order?', 'Last in, first out.'],
          <String>['Queue order?', 'First in, first out.'],
        ]),
      ),
    ];
  }

  List<Flashcard> _cards(List<List<String>> pairs) {
    return pairs
        .asMap()
        .entries
        .map(
          (MapEntry<int, List<String>> entry) => Flashcard(
            id: 'card-${entry.key + 1}',
            front: entry.value.first,
            back: entry.value.last,
            state: entry.key == 0
                ? FlashcardState.mastered
                : entry.key == 1
                ? FlashcardState.reviewAgain
                : FlashcardState.newCard,
          ),
        )
        .toList(growable: true);
  }

  List<MockExam> _sampleMockExams() {
    return <MockExam>[
      MockExam(
        id: 'mock-1',
        ownerId: demoStudentId,
        title: 'My Math Mock Exam',
        timeLimitMin: 15,
        lastScore: 8,
        questions: const <Question>[
          Question(
            id: 'mq1',
            type: QuestionType.truefalse,
            prompt: 'A linear function has a constant slope.',
            choices: <String>['True', 'False'],
            answerIndex: 0,
            points: 1,
          ),
          Question(
            id: 'mq2',
            type: QuestionType.mcq,
            prompt: 'What is the slope of y = 4x − 2?',
            choices: <String>['−2', '2', '4', '6'],
            answerIndex: 2,
            points: 1,
          ),
        ],
      ),
    ];
  }
}
