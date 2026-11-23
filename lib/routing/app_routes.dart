import 'package:flutter/material.dart';

import '../models/course.dart';
import '../screens/assignment.dart';
import '../screens/booking_detail.dart';
import '../screens/bookings.dart';
import '../screens/browse.dart';
import '../screens/checkout.dart';
import '../screens/confirmation.dart';
import '../screens/course_detail_screen.dart';
import '../screens/deck_form.dart';
import '../screens/exam_intro.dart';
import '../screens/flashcard_runner.dart';
import '../screens/grading.dart';
import '../screens/mock_exam_builder.dart';
import '../screens/onboarding.dart';
import '../screens/reschedule.dart';
import '../screens/role_select.dart';
import '../screens/student_classroom.dart';
import '../screens/student_detail.dart';
import '../screens/student_home.dart';
import '../screens/study_studio.dart';
import '../screens/study_summary.dart';
import '../screens/quiz_runner.dart';
import '../screens/tutor_availability_screen.dart';
import '../screens/tutor_classroom.dart';
import '../screens/tutor_dashboard.dart';
import '../screens/tutor_earnings.dart';
import '../screens/tutor_profile_verification.dart';
import '../screens/tutor_profile.dart';
import '../screens/tutor_students.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String roleSelect = '/role-select';
  static const String studentHome = '/student-home';
  static const String browse = '/browse';
  static const String tutorProfile = '/tutor-profile';
  static const String checkout = '/checkout';
  static const String confirmation = '/confirmation';
  static const String bookings = '/bookings';
  static const String bookingDetail = '/booking-detail';
  static const String reschedule = '/reschedule';
  static const String studentClassroom = '/student-classroom';
  static const String assignment = '/assignment';
  static const String examIntro = '/exam-intro';
  static const String quiz = '/quiz';
  static const String study = '/study';
  static const String flashcards = '/flashcards';
  static const String deckForm = '/deck-form';
  static const String cardForm = '/card-form';
  static const String mockBuilder = '/mock-builder';
  static const String studySummary = '/study-summary';
  static const String tutorDashboard = '/tutor-dashboard';
  static const String tutorStudents = '/tutor-students';
  static const String studentDetail = '/student-detail';
  static const String tutorClassroom = '/tutor-classroom';
  static const String grading = '/grading';
  static const String tutorEarnings = '/tutor-earnings';
  static const String tutorProfileVerification = '/tutor-profile-settings';
  static const String tutorAvailability = '/tutor-availability';
  static const String courseDetail = '/course-detail';

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    onboarding: (BuildContext context) => const OnboardingScreen(),
    roleSelect: (BuildContext context) => const RoleSelectScreen(),
    studentHome: (BuildContext context) => const StudentHomeScreen(),
    browse: (BuildContext context) => const BrowseScreen(),
    tutorProfile: (BuildContext context) => const TutorProfileScreen(),
    checkout: (BuildContext context) => const CheckoutScreen(),
    confirmation: (BuildContext context) => const ConfirmationScreen(),
    bookings: (BuildContext context) => const BookingsScreen(),
    bookingDetail: (BuildContext context) => const BookingDetailScreen(),
    reschedule: (BuildContext context) => const RescheduleScreen(),
    studentClassroom: (BuildContext context) => const StudentClassroomScreen(),
    assignment: (BuildContext context) => const AssignmentScreen(),
    examIntro: (BuildContext context) => const ExamIntroScreen(),
    quiz: (BuildContext context) => const QuizRunnerScreen(),
    study: (BuildContext context) => const StudyStudioScreen(),
    flashcards: (BuildContext context) => const FlashcardRunnerScreen(),
    deckForm: (BuildContext context) => const DeckFormScreen(),
    cardForm: (BuildContext context) => const DeckFormScreen(cardMode: true),
    mockBuilder: (BuildContext context) => const MockExamBuilderScreen(),
    studySummary: (BuildContext context) => const StudySummaryScreen(),
    tutorDashboard: (BuildContext context) => const TutorDashboardScreen(),
    tutorStudents: (BuildContext context) => const TutorStudentsScreen(),
    studentDetail: (BuildContext context) => const StudentDetailScreen(),
    tutorClassroom: (BuildContext context) => const TutorClassroomScreen(),
    grading: (BuildContext context) => const GradingScreen(),
    tutorEarnings: (BuildContext context) => const TutorEarningsScreen(),
    tutorProfileVerification: (BuildContext context) =>
        const TutorProfileVerificationScreen(),
    tutorAvailability: (BuildContext context) =>
        const TutorAvailabilityScreen(),
    courseDetail: (BuildContext context) {
      final Course? course =
          ModalRoute.of(context)?.settings.arguments as Course?;
      if (course == null) {
        return const Scaffold(body: Center(child: Text('Course not found')));
      }
      return CourseDetailScreen(course: course);
    },
  };
}
