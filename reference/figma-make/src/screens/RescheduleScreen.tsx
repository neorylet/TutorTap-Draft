import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { PillButton } from "../components/PillButton";
import { SlotCell } from "../components/SlotCell";
import { useAppState } from "../state/AppState";

export function RescheduleScreen() {
  const [slot, setSlot] = useState<string | null>(null);
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Reschedule" />
      <h2>Select a new online time</h2>
      <p className="muted">Ana Reyes · Math · 1 hour</p>
      <div className="date-strip">
        {["Sat 20", "Sun 21", "Mon 22", "Tue 23"].map((d, i) => (
          <button className={i === 1 ? "active" : ""} key={d}>
            <span>{d.split(" ")[0]}</span>
            <strong>{d.split(" ")[1]}</strong>
          </button>
        ))}
      </div>
      <div className="slot-grid">
        {["9:00 AM", "10:00 AM", "1:00 PM", "2:00 PM", "4:00 PM", "5:00 PM"].map((s) => (
          <SlotCell
            key={s}
            time={s}
            state={slot === s ? "selected" : "available"}
            onClick={() => setSlot(s)}
          />
        ))}
      </div>
      <PillButton disabled={!slot} onClick={() => go("booking-detail")}>
        Save new time
      </PillButton>
    </div>
  );
}
