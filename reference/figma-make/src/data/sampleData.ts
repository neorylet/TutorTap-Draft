export type Tutor = {
  id: string;
  name: string;
  initials: string;
  subjects: string[];
  rate: number;
  rating: number;
  reviews: number;
};

export const tutors: Tutor[] = [
  {
    id: "ana",
    name: "Ana Reyes",
    initials: "AR",
    subjects: ["Math"],
    rate: 450,
    rating: 4.9,
    reviews: 128,
  },
  {
    id: "ben",
    name: "Ben Castillo",
    initials: "BC",
    subjects: ["Computer Science"],
    rate: 600,
    rating: 4.8,
    reviews: 96,
  },
  {
    id: "carla",
    name: "Carla Dizon",
    initials: "CD",
    subjects: ["English"],
    rate: 380,
    rating: 4.7,
    reviews: 74,
  },
  {
    id: "daniel",
    name: "Daniel Ocampo",
    initials: "DO",
    subjects: ["Math", "Computer Science"],
    rate: 520,
    rating: 4.6,
    reviews: 63,
  },
  {
    id: "elise",
    name: "Elise Tan",
    initials: "ET",
    subjects: ["English"],
    rate: 420,
    rating: 4.9,
    reviews: 112,
  },
  {
    id: "francis",
    name: "Francis Lim",
    initials: "FL",
    subjects: ["Computer Science"],
    rate: 550,
    rating: 4.5,
    reviews: 58,
  },
];

export const bookings = [
  {
    id: "b1",
    tutor: "Ana Reyes",
    subject: "Math",
    schedule: "Sat, Dec 20 · 2:00–3:00 PM",
    status: "confirmed" as const,
  },
  {
    id: "b2",
    tutor: "Carla Dizon",
    subject: "English",
    schedule: "Mon, Dec 22 · 5:00–6:00 PM",
    status: "pending" as const,
  },
  {
    id: "b3",
    tutor: "Daniel Ocampo",
    subject: "Computer Science",
    schedule: "Dec 11 · 4:00–5:00 PM",
    status: "completed" as const,
  },
  {
    id: "b4",
    tutor: "Ben Castillo",
    subject: "Computer Science",
    schedule: "Dec 4 · 1:00–2:00 PM",
    status: "cancelled" as const,
  },
];

export const decks = [
  { id: "limits", title: "Calculus Limits", subject: "Math", cards: 12, mastered: 7, review: 5 },
  {
    id: "structures",
    title: "Data Structures",
    subject: "Computer Science",
    cards: 20,
    mastered: 12,
    review: 8,
  },
];

export const assignments = [
  { id: "hw1", title: "Homework 1: Linear Equations", due: "Dec 22", status: "assigned" },
  { id: "hw2", title: "Graphing Functions", due: "Dec 18", status: "graded" },
];

export const students = [
  { id: "mika", name: "Mika Santos", initials: "MS", subject: "Math", sessions: 6, grade: 92 },
  {
    id: "joaquin",
    name: "Joaquin Perez",
    initials: "JP",
    subject: "Computer Science",
    sessions: 4,
    grade: 85,
  },
  { id: "lia", name: "Lia Navarro", initials: "LN", subject: "English", sessions: 9, grade: 90 },
  { id: "rafael", name: "Rafael Uy", initials: "RU", subject: "Math", sessions: 2, grade: 78 },
];

export const exams = [
  {
    id: "quiz1",
    title: "Quiz 1: Functions",
    questions: 10,
    minutes: 15,
    due: "Dec 23",
    score: null,
  },
  {
    id: "midterm",
    title: "Midterm Review",
    questions: 20,
    minutes: 30,
    due: "Dec 28",
    score: "8/10",
  },
];

export const quizQuestions = [
  {
    prompt: "Which equation represents a linear function?",
    choices: ["y = 2x + 3", "y = x²", "y = 1/x", "y = √x"],
    answer: 0,
  },
  { prompt: "What is the slope of y = 4x − 2?", choices: ["−2", "2", "4", "6"], answer: 2 },
  { prompt: "What is the derivative of x²?", choices: ["x", "2x", "x²/2", "2"], answer: 1 },
];

export const meetingLink = "meet.tutortap.app/ana-math-2014";
