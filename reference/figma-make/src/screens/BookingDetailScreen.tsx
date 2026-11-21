import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { Icon } from "../components/Icon";
import { PillButton } from "../components/PillButton";
import { StatusBadge } from "../components/StatusBadge";
import { meetingLink } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function BookingDetailScreen() {
  const { bookingCancelled, setBookingCancelled, go } = useAppState();
  const [sheet, setSheet] = useState(false);
  return (
    <div className="screen">
      <AppBar title="Booking details" />
      <div className="booking-hero">
        <span className="avatar large">AR</span>
        <h1>Math with Ana Reyes</h1>
        <StatusBadge status={bookingCancelled ? "cancelled" : "confirmed"} />
      </div>
      <div className="card detail-list">
        <div>
          <Icon name="calendar" />
          <span>
            <small>Schedule</small>
            <strong>Sat, Dec 20 · 2:00–3:00 PM</strong>
          </span>
        </div>
        <div>
          <Icon name="video" />
          <span>
            <small>Online room</small>
            <strong>{meetingLink}</strong>
          </span>
          <button>Copy</button>
        </div>
      </div>
      <PillButton disabled={bookingCancelled}>Join online session</PillButton>
      <small className="helper center">Opens 10 min before</small>
      <div className="button-pair">
        <PillButton
          variant="secondary"
          disabled={bookingCancelled}
          onClick={() => go("reschedule")}
        >
          Reschedule
        </PillButton>
        <PillButton variant="text" disabled={bookingCancelled} onClick={() => setSheet(true)}>
          Cancel
        </PillButton>
      </div>
      {sheet && (
        <div className="sheet-backdrop">
          <div className="bottom-sheet">
            <div className="sheet-handle" />
            <h2>Cancel this session?</h2>
            <p>Ana will be notified. The cancellation policy may apply.</p>
            <PillButton
              variant="amber"
              onClick={() => {
                setBookingCancelled(true);
                setSheet(false);
              }}
            >
              Cancel booking
            </PillButton>
            <PillButton variant="text" onClick={() => setSheet(false)}>
              Keep session
            </PillButton>
          </div>
        </div>
      )}
    </div>
  );
}
