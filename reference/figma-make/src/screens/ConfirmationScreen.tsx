import { LottieSlot } from "../components/LottieSlot";
import { PillButton } from "../components/PillButton";
import { StatusBadge } from "../components/StatusBadge";
import { meetingLink } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function ConfirmationScreen() {
  const { go } = useAppState();
  return (
    <div className="screen confirmation">
      <LottieSlot file="booking_success.json" size={200} />
      <h1>Booking confirmed</h1>
      <p className="muted">Ana has received your session details.</p>
      <div className="card confirmation-card">
        <StatusBadge status="confirmed" />
        <strong>Math with Ana Reyes</strong>
        <p>Sat, Dec 20 · 2:00–3:00 PM</p>
        <div className="meeting-link">
          <span>
            Online session link:
            <br />
            {meetingLink}
          </span>
          <button onClick={() => navigator.clipboard?.writeText(meetingLink)}>Copy</button>
        </div>
      </div>
      <PillButton onClick={() => go("booking-detail")}>View booking</PillButton>
      <PillButton variant="text" onClick={() => go("student-home")}>
        Back to Home
      </PillButton>
    </div>
  );
}
