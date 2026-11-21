import { useState } from "react";
import { HeroPlaceholder } from "../components/HeroPlaceholder";
import { LottieSlot } from "../components/LottieSlot";
import { PillButton } from "../components/PillButton";
import { useAppState } from "../state/AppState";

const steps = [
  ["Find a tutor who fits.", "Browse verified online tutors by subject, rate, and rating."],
  [
    "Learn inside one classroom.",
    "Modules, assignments, grades, and exams from your tutor, all in one place.",
  ],
  [
    "Study on your own time.",
    "Build flashcards and mock exams, then focus on what you haven't mastered.",
  ],
];
export function OnboardingScreen() {
  const [step, setStep] = useState(0);
  const { go } = useAppState();
  return (
    <div className="screen onboarding">
      <button className="skip" onClick={() => go("auth")}>
        Skip
      </button>
      <div className="onboarding-visual">
        {step === 0 ? <LottieSlot file="welcome_study.json" size={220} /> : <HeroPlaceholder />}
      </div>
      <div className="onboarding-copy">
        <h1>{steps[step][0]}</h1>
        <p>{steps[step][1]}</p>
        <div className="step-pills">
          {steps.map((_, i) => (
            <span key={i} className={i === step ? "active" : ""} />
          ))}
        </div>
      </div>
      <PillButton onClick={() => (step === 2 ? go("auth") : setStep(step + 1))}>
        {step === 2 ? "Get Started" : "Next"}
      </PillButton>
    </div>
  );
}
