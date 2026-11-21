import { useState } from "react";
import { HeroPlaceholder } from "../components/HeroPlaceholder";
import { Icon } from "../components/Icon";
import { ListRow } from "../components/ListRow";
import { PillButton } from "../components/PillButton";
import { ProgressBar } from "../components/ProgressBar";
import { StatusBadge } from "../components/StatusBadge";
import { meetingLink } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function StudentHome() {
  const { go, setRole } = useAppState();
  const [sheet, setSheet] = useState(false);
  const [copied, setCopied] = useState(false);
  return (
    <div className="screen tab-screen">
      <div className="home-head">
        <div>
          <small>Saturday, December 19</small>
          <h1>Good afternoon, Mika</h1>
        </div>
        <button className="avatar-button" onClick={() => setSheet(true)}>
          MS
        </button>
      </div>
      <HeroPlaceholder compact />
      <section>
        <div className="section-head">
          <h2>Next Online Session</h2>
          <span className="countdown">Starts in 1d 4h</span>
        </div>
        <div
          className="card session-card"
          role="button"
          tabIndex={0}
          onClick={() => go("booking-detail")}
          onKeyDown={(event) => {
            if (event.key === "Enter") go("booking-detail");
          }}
        >
          <div className="person-line">
            <span className="avatar small">AR</span>
            <div>
              <strong>Ana Reyes</strong>
              <small>Math · Sat, Dec 20 · 2:00–3:00 PM</small>
            </div>
            <StatusBadge status="confirmed" />
          </div>
          <div className="meeting-link">
            <Icon name="video" size={18} />
            <span>{meetingLink}</span>
            <button
              onClick={(e) => {
                e.stopPropagation();
                setCopied(true);
                navigator.clipboard?.writeText(meetingLink);
              }}
            >
              {copied ? "Copied" : "Copy"}
            </button>
          </div>
          <PillButton disabled>Join session</PillButton>
          <small className="helper">Opens 10 min before</small>
        </div>
      </section>
      <section>
        <h2>Due Soon</h2>
        <div className="card flush">
          <ListRow
            title="Homework 1: Linear Equations"
            meta="Due Dec 22"
            action={<span className="due">2 days</span>}
            onClick={() => go("assignment")}
          />
          <ListRow
            title="Quiz 1: Functions"
            meta="10 questions · Due Dec 23"
            action={<span className="due">3 days</span>}
            onClick={() => go("exam-intro")}
          />
        </div>
      </section>
      <section>
        <h2>Continue Studying</h2>
        <div className="card study-card-content">
          <div>
            <strong>Calculus Limits</strong>
            <span>Card 4 of 12</span>
          </div>
          <ProgressBar value={58} />
          <p>Mastered 7 · Review Again 5</p>
          <PillButton onClick={() => go("flashcards")}>Resume</PillButton>
        </div>
      </section>
      <button className="link-row" onClick={() => go("browse")}>
        Find a new tutor <Icon name="chevron" size={18} />
      </button>
      {sheet && (
        <div className="sheet-backdrop" onClick={() => setSheet(false)}>
          <div className="bottom-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="sheet-handle" />
            <h2>Mika Santos</h2>
            <ListRow
              icon="book"
              title="Account"
              meta="Student profile"
              onClick={() => setSheet(false)}
            />
            <ListRow
              icon="book"
              title="Switch role (demo)"
              meta="Open tutor workspace"
              onClick={() => {
                setRole("tutor");
                go("tutor-dashboard");
                setSheet(false);
              }}
            />
            <ListRow icon="book" title="Sign out" onClick={() => go("auth")} />
          </div>
        </div>
      )}
    </div>
  );
}
