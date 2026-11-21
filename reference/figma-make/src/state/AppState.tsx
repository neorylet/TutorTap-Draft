import { createContext, useContext, useMemo, useState, type ReactNode } from "react";

export type Role = "student" | "tutor";
export type DemoState = "default" | "empty" | "slot-error" | "uploading" | "upload-failed";
export type Screen =
  | "onboarding"
  | "auth"
  | "role-select"
  | "student-home"
  | "browse"
  | "tutor-profile"
  | "checkout"
  | "confirmation"
  | "bookings"
  | "booking-detail"
  | "reschedule"
  | "student-classroom"
  | "assignment"
  | "exam-intro"
  | "quiz"
  | "study"
  | "flashcards"
  | "deck-form"
  | "card-form"
  | "mock-builder"
  | "study-summary"
  | "tutor-dashboard"
  | "tutor-students"
  | "student-detail"
  | "tutor-classroom"
  | "grading"
  | "tutor-earnings"
  | "tutor-profile-settings";

type State = {
  screen: Screen;
  role: Role;
  demo: DemoState;
  selectedTutor: string;
  selectedSlot: string | null;
  bookingCancelled: boolean;
  go: (screen: Screen) => void;
  back: () => void;
  setRole: (role: Role) => void;
  setSelectedTutor: (id: string) => void;
  setSelectedSlot: (slot: string | null) => void;
  setBookingCancelled: (value: boolean) => void;
  forceDemo: (state: DemoState) => void;
};

const AppContext = createContext<State | null>(null);

export function AppStateProvider({ children }: { children: ReactNode }) {
  const [screen, setScreen] = useState<Screen>("onboarding");
  const [history, setHistory] = useState<Screen[]>([]);
  const [role, setRole] = useState<Role>("student");
  const [demo, setDemo] = useState<DemoState>("default");
  const [selectedTutor, setSelectedTutor] = useState("ana");
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const [bookingCancelled, setBookingCancelled] = useState(false);

  const go = (next: Screen) => {
    setHistory((items) => [...items, screen]);
    setScreen(next);
  };
  const back = () => {
    const previous = history.at(-1);
    if (!previous) return;
    setHistory((items) => items.slice(0, -1));
    setScreen(previous);
  };
  const forceDemo = (state: DemoState) => {
    setDemo(state);
    setHistory([]);
    if (state === "default") {
      setRole("student");
      setSelectedSlot(null);
      setScreen("student-home");
    } else if (state === "empty") {
      setScreen("browse");
    } else if (state === "slot-error") {
      setSelectedTutor("ana");
      setScreen("tutor-profile");
    } else {
      setRole("tutor");
      setScreen("tutor-profile-settings");
    }
  };
  const value = useMemo(
    () => ({
      screen,
      role,
      demo,
      selectedTutor,
      selectedSlot,
      bookingCancelled,
      go,
      back,
      setRole,
      setSelectedTutor,
      setSelectedSlot,
      setBookingCancelled,
      forceDemo,
    }),
    [screen, role, demo, selectedTutor, selectedSlot, bookingCancelled],
  );
  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useAppState() {
  const value = useContext(AppContext);
  if (!value) throw new Error("useAppState must be used within AppStateProvider");
  return value;
}
