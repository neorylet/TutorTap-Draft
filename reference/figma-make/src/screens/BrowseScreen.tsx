import { useState } from "react";
import { FilterChip } from "../components/FilterChip";
import { Icon } from "../components/Icon";
import { LottieSlot } from "../components/LottieSlot";
import { PillButton } from "../components/PillButton";
import { TutorCard } from "../components/TutorCard";
import { tutors } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function BrowseScreen() {
  const { demo, go, setSelectedTutor } = useAppState();
  const [grid, setGrid] = useState(false);
  const [subject, setSubject] = useState("");
  const empty = demo === "empty" || subject === "No match";
  return (
    <div className="screen tab-screen">
      <div className="browse-title">
        <h1>Find a tutor</h1>
        <p>Vetted tutors for focused online learning.</p>
      </div>
      <label className="search-field">
        <Icon name="search" size={18} />
        <input placeholder="Search subject or tutor name" />
      </label>
      <div className="chip-scroll">
        <FilterChip
          label="Subject"
          active={!!subject}
          onClick={() => setSubject(subject ? "" : "Math")}
        />
        <FilterChip label="Rate (₱/hr)" onClick={() => setSubject("No match")} />
        <FilterChip label="Rating 4.5+" />
        <FilterChip label="Available this week" />
      </div>
      <div className="count-row">
        <strong>{empty ? "0" : "24"} tutors</strong>
        <div className="view-toggle">
          <button className={!grid ? "active" : ""} onClick={() => setGrid(false)}>
            <Icon name="list" size={18} />
          </button>
          <button className={grid ? "active" : ""} onClick={() => setGrid(true)}>
            <Icon name="grid" size={18} />
          </button>
        </div>
      </div>
      {empty ? (
        <div className="empty-state">
          <LottieSlot file="empty_search.json" size={160} />
          <h2>No tutors match these filters</h2>
          <p>Try a wider rate range or another subject.</p>
          <PillButton variant="secondary" onClick={() => setSubject("")}>
            Clear filters
          </PillButton>
        </div>
      ) : (
        <div className={grid ? "tutor-grid" : "tutor-list"}>
          {tutors
            .filter((t) => !subject || t.subjects.includes(subject))
            .map((tutor) => (
              <TutorCard
                key={tutor.id}
                tutor={tutor}
                grid={grid}
                onClick={() => {
                  setSelectedTutor(tutor.id);
                  go("tutor-profile");
                }}
              />
            ))}
        </div>
      )}
    </div>
  );
}
