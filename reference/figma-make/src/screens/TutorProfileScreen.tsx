import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { HeroPlaceholder } from "../components/HeroPlaceholder";
import { ListRow } from "../components/ListRow";
import { PillButton } from "../components/PillButton";
import { SlotCell } from "../components/SlotCell";
import { StatusBadge } from "../components/StatusBadge";
import { Toast } from "../components/Toast";
import { tutors } from "../data/sampleData";
import { useAppState } from "../state/AppState";

const slots = [
  "9:00 AM",
  "10:00 AM",
  "11:00 AM",
  "1:00 PM",
  "2:00 PM",
  "3:00 PM",
  "4:00 PM",
  "5:00 PM",
  "6:00 PM",
];
export function TutorProfileScreen() {
  const { selectedTutor, selectedSlot, setSelectedSlot, demo, go } = useAppState();
  const tutor = tutors.find((item) => item.id === selectedTutor) ?? tutors[0];
  const [tab, setTab] = useState("About");
  const [date, setDate] = useState(1);
  const error = demo === "slot-error";
  return (
    <div className="screen detail-screen">
      <AppBar title="Tutor profile" />
      <HeroPlaceholder compact />
      <div className="profile-intro">
        <span className="avatar large">{tutor.initials}</span>
        <h1>
          {tutor.name} <StatusBadge status="Verified" />
        </h1>
        <p>
          ★ {tutor.rating} · {tutor.reviews} reviews · ₱{tutor.rate}/hr · Online sessions
        </p>
      </div>
      {error && (
        <>
          <Toast>That slot was just taken.</Toast>
          <div className="error-banner">That slot was just taken. Pick another time.</div>
        </>
      )}
      <div className="inner-tabs">
        {["About", "Credentials", "Reviews"].map((item) => (
          <button className={tab === item ? "active" : ""} onClick={() => setTab(item)} key={item}>
            {item}
          </button>
        ))}
      </div>
      <div className="tab-content">
        {tab === "About" && (
          <p>
            I help students build confidence in algebra and calculus through clear worked examples,
            active practice, and short weekly learning plans.
          </p>
        )}
        {tab === "Credentials" && (
          <div className="card flush">
            <ListRow title="BS Mathematics, Univ. of Mindanao" tag="Verified document" />
            <ListRow title="LET Passer" tag="Verified document" />
            <ListRow title="5 yrs tutoring experience" tag="Verified document" />
          </div>
        )}
        {tab === "Reviews" && (
          <div className="reviews">
            {[
              "Mika · Ana makes every step easy to follow.",
              "Rafael · Patient with difficult algebra topics.",
              "Lia · The practice sets are very useful.",
            ].map((r) => (
              <p key={r}>{r}</p>
            ))}
          </div>
        )}
      </div>
      <section>
        <h2>Choose a date</h2>
        <div className="date-strip">
          {["Fri 19", "Sat 20", "Sun 21", "Mon 22", "Tue 23", "Wed 24", "Thu 25"].map((day, i) => (
            <button key={day} className={date === i ? "active" : ""} onClick={() => setDate(i)}>
              <span>{day.split(" ")[0]}</span>
              <strong>{day.split(" ")[1]}</strong>
            </button>
          ))}
        </div>
      </section>
      <section>
        <h2>Available online times</h2>
        <div className="slot-grid">
          {slots.map((slot, i) => (
            <SlotCell
              key={slot}
              time={slot}
              state={
                error && slot === "2:00 PM"
                  ? "taken"
                  : i === 2
                    ? "taken"
                    : selectedSlot === slot
                      ? "selected"
                      : i === 5
                        ? "locked"
                        : "available"
              }
              onClick={() => setSelectedSlot(slot)}
            />
          ))}
        </div>
        <div className="legend">
          <span className="available">Available</span>
          <span className="selected">Selected</span>
          <span className="locked">Locked by you</span>
          <span className="taken">Taken</span>
        </div>
      </section>
      <div className="sticky-cta">
        <div>
          <strong>₱{tutor.rate}</strong>
          <small>1 hr · Online</small>
        </div>
        <PillButton disabled={!selectedSlot} onClick={() => go("checkout")}>
          Continue to checkout
        </PillButton>
      </div>
    </div>
  );
}
