import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { FilterChip } from "../components/FilterChip";
import { PillButton } from "../components/PillButton";
import { ProgressBar } from "../components/ProgressBar";
import { useAppState } from "../state/AppState";

export function FlashcardRunner() {
  const [flipped, setFlipped] = useState(false);
  const [card, setCard] = useState(4);
  const [filter, setFilter] = useState("All");
  const { go } = useAppState();
  const next = () => (card >= 6 ? go("study-summary") : (setCard(card + 1), setFlipped(false)));
  return (
    <div className="screen">
      <AppBar title="Calculus Limits" />
      <div className="chip-row">
        {["All", "Review Again", "Mastered"].map((item) => (
          <FilterChip
            key={item}
            label={item}
            active={filter === item}
            onClick={() => setFilter(item)}
          />
        ))}
      </div>
      <ProgressBar value={(card / 12) * 100} label={`Card ${card} of 12`} />
      <button
        className={`flip-card ${flipped ? "flipped" : ""}`}
        onClick={() => setFlipped(!flipped)}
      >
        <small>{flipped ? "ANSWER" : "QUESTION"}</small>
        <strong>{flipped ? "2x" : "What is the derivative of x²?"}</strong>
        <span>Tap to {flipped ? "see question" : "reveal answer"}</span>
      </button>
      <div className="button-pair">
        <PillButton variant="amber" onClick={next}>
          Review Again
        </PillButton>
        <PillButton onClick={next}>Mastered</PillButton>
      </div>
    </div>
  );
}
