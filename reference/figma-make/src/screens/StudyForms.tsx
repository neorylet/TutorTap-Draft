import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { FormField } from "../components/FormField";
import { PillButton } from "../components/PillButton";
import { useAppState } from "../state/AppState";

export function DeckForm({ card = false }: { card?: boolean }) {
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title={card ? "Add card" : "New deck"} />
      <h2>{card ? "Write a clear prompt" : "Set up your deck"}</h2>
      <div className="form-stack">
        {card ? (
          <>
            <FormField label="Front" placeholder="Question or term" textarea />
            <FormField label="Back" placeholder="Answer or definition" textarea />
          </>
        ) : (
          <>
            <FormField label="Deck title" placeholder="e.g. Calculus Limits" />
            <FormField label="Subject" placeholder="Math" />
          </>
        )}
      </div>
      <PillButton onClick={() => go(card ? "study" : "card-form")}>
        {card ? "Save & add another" : "Continue to cards"}
      </PillButton>
    </div>
  );
}

export function MockExamBuilder() {
  const [correct, setCorrect] = useState(0);
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Create mock exam" />
      <FormField label="Title" placeholder="Calculus Practice 02" />
      <FormField label="Time limit" placeholder="20 minutes" />
      <div className="builder-card card">
        <h2>Question 1</h2>
        <FormField label="Prompt" placeholder="Write the question" textarea />
        {["Choice A", "Choice B", "Choice C", "Choice D"].map((label, i) => (
          <label className="choice-field" key={label}>
            <input
              type="radio"
              checked={correct === i}
              onChange={() => setCorrect(i)}
              name="correct"
            />
            <input placeholder={label} />
          </label>
        ))}
      </div>
      <PillButton variant="secondary">Add another question</PillButton>
      <PillButton onClick={() => go("study")}>Save mock exam</PillButton>
    </div>
  );
}

export function StudySummary() {
  const { go } = useAppState();
  return (
    <div className="screen confirmation">
      <div className="score-ring">
        <strong>8</strong>
        <span>cards reviewed</span>
      </div>
      <h1>Session complete</h1>
      <p className="muted">You mastered 5 cards and marked 3 to review again.</p>
      <div className="mastery-summary">
        <div>
          <strong>5</strong>
          <span>Mastered</span>
        </div>
        <i />
        <div>
          <strong>3</strong>
          <span>Review Again</span>
        </div>
      </div>
      <PillButton onClick={() => go("study")}>Back to Study Studio</PillButton>
    </div>
  );
}
