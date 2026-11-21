import { DemoStatesBar } from "./components/DemoStatesBar";
import { QuizRunner } from "./components/QuizRunner";
import { TabBar } from "./components/TabBar";
import { AppStateProvider, useAppState, type Screen } from "./state/AppState";
import { AssignmentScreen } from "./screens/AssignmentScreen";
import { AuthScreen } from "./screens/AuthScreen";
import { BookingDetailScreen } from "./screens/BookingDetailScreen";
import { BookingsScreen } from "./screens/BookingsScreen";
import { BrowseScreen } from "./screens/BrowseScreen";
import { CheckoutScreen } from "./screens/CheckoutScreen";
import { ConfirmationScreen } from "./screens/ConfirmationScreen";
import { ExamIntroScreen } from "./screens/ExamIntroScreen";
import { FlashcardRunner } from "./screens/FlashcardRunner";
import { GradingScreen } from "./screens/GradingScreen";
import { OnboardingScreen } from "./screens/OnboardingScreen";
import { RescheduleScreen } from "./screens/RescheduleScreen";
import { RoleSelectScreen } from "./screens/RoleSelectScreen";
import { StudentClassroom } from "./screens/StudentClassroom";
import { StudentDetailScreen } from "./screens/StudentDetailScreen";
import { StudentHome } from "./screens/StudentHome";
import { DeckForm, MockExamBuilder, StudySummary } from "./screens/StudyForms";
import { StudyStudio } from "./screens/StudyStudio";
import { TutorClassroom } from "./screens/TutorClassroom";
import { TutorDashboard } from "./screens/TutorDashboard";
import { TutorEarnings } from "./screens/TutorEarnings";
import { TutorProfileVerification } from "./screens/TutorProfileVerification";
import { TutorProfileScreen } from "./screens/TutorProfileScreen";
import { TutorStudents } from "./screens/TutorStudents";

const tabScreens = new Set<Screen>([
  "student-home",
  "browse",
  "bookings",
  "student-classroom",
  "study",
  "tutor-dashboard",
  "tutor-students",
  "tutor-classroom",
  "tutor-earnings",
  "tutor-profile-settings",
]);

function Router() {
  const { screen } = useAppState();
  const screens: Record<Screen, React.ReactNode> = {
    onboarding: <OnboardingScreen />,
    auth: <AuthScreen />,
    "role-select": <RoleSelectScreen />,
    "student-home": <StudentHome />,
    browse: <BrowseScreen />,
    "tutor-profile": <TutorProfileScreen />,
    checkout: <CheckoutScreen />,
    confirmation: <ConfirmationScreen />,
    bookings: <BookingsScreen />,
    "booking-detail": <BookingDetailScreen />,
    reschedule: <RescheduleScreen />,
    "student-classroom": <StudentClassroom />,
    assignment: <AssignmentScreen />,
    "exam-intro": <ExamIntroScreen />,
    quiz: <QuizRunner />,
    study: <StudyStudio />,
    flashcards: <FlashcardRunner />,
    "deck-form": <DeckForm />,
    "card-form": <DeckForm card />,
    "mock-builder": <MockExamBuilder />,
    "study-summary": <StudySummary />,
    "tutor-dashboard": <TutorDashboard />,
    "tutor-students": <TutorStudents />,
    "student-detail": <StudentDetailScreen />,
    "tutor-classroom": <TutorClassroom />,
    grading: <GradingScreen />,
    "tutor-earnings": <TutorEarnings />,
    "tutor-profile-settings": <TutorProfileVerification />,
  };
  return (
    <main className="phone-shell">
      <DemoStatesBar />
      <div className="status-bar">
        <span>9:41</span>
        <span>● ● ▰</span>
      </div>
      <div className="screen-viewport">{screens[screen]}</div>
      {tabScreens.has(screen) && <TabBar />}
    </main>
  );
}

export default function App() {
  return (
    <AppStateProvider>
      <Router />
    </AppStateProvider>
  );
}
