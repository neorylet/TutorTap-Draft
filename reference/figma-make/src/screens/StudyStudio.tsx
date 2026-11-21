import { useState } from "react";
import { Icon } from "../components/Icon";
import { PillButton } from "../components/PillButton";
import { ProgressBar } from "../components/ProgressBar";
import { SegmentedControl } from "../components/SegmentedControl";
import { decks } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function StudyStudio() {
  const [tab, setTab] = useState("Flashcards");
  const { go } = useAppState();
  return (
    <div className="screen tab-screen">
      <h1>Study Studio</h1>
      <p className="muted">Your private space to practice.</p>
      <SegmentedControl items={["Flashcards", "Mock Exams"]} value={tab} onChange={setTab} />
      <div className="mastery-summary">
        <div>
          <strong>7</strong>
          <span>Mastered</span>
        </div>
        <i />
        <div>
          <strong>5</strong>
          <span>Review Again</span>
        </div>
      </div>
      {tab === "Flashcards" ? (
        <>
          <div className="section-head">
            <h2>Your decks</h2>
            <button className="circle-action" onClick={() => go("deck-form")}>
              <Icon name="plus" /> New deck
            </button>
          </div>
          <div className="stack">
            {decks.map((deck) => (
              <button className="card deck-card" key={deck.id} onClick={() => go("flashcards")}>
                <div className="deck-icon">
                  <Icon name="book" />
                </div>
                <div>
                  <strong>{deck.title}</strong>
                  <small>
                    {deck.subject} · {deck.cards} cards
                  </small>
                  <ProgressBar value={(deck.mastered / deck.cards) * 100} />
                </div>
                <Icon name="chevron" size={18} />
              </button>
            ))}
          </div>
        </>
      ) : (
        <>
          <div className="section-head">
            <h2>Mock exams</h2>
            <button className="circle-action" onClick={() => go("mock-builder")}>
              <Icon name="plus" /> Create
            </button>
          </div>
          <div className="card mock-card" role="button" tabIndex={0} onClick={() => go("quiz")}>
            <div>
              <strong>Calculus Practice 01</strong>
              <small>10 questions · 20 min</small>
            </div>
            <PillButton>Start</PillButton>
          </div>
          <div className="card mock-card" role="button" tabIndex={0} onClick={() => go("quiz")}>
            <div>
              <strong>Data Structures Review</strong>
              <small>15 questions · 25 min</small>
            </div>
            <PillButton>Start</PillButton>
          </div>
        </>
      )}
    </div>
  );
}
