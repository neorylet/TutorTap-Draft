import { useState } from "react";
import { Icon } from "../components/Icon";
import { SegmentedControl } from "../components/SegmentedControl";
import { StatusBadge } from "../components/StatusBadge";
import { bookings } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function BookingsScreen() {
  const [segment, setSegment] = useState("Upcoming");
  const { go } = useAppState();
  const shown = segment === "Upcoming" ? bookings.slice(0, 2) : bookings.slice(2);
  return (
    <div className="screen tab-screen">
      <h1>Bookings</h1>
      <p className="muted">Your online tutoring schedule.</p>
      <SegmentedControl items={["Upcoming", "Past"]} value={segment} onChange={setSegment} />
      <div className="booking-list">
        {shown.map((booking) => (
          <button
            className="card booking-row"
            key={booking.id}
            onClick={() => go("booking-detail")}
          >
            <div className="booking-date">
              <strong>{booking.schedule.split(" ")[1]}</strong>
              <span>DEC</span>
            </div>
            <div>
              <strong>
                {booking.subject} with {booking.tutor}
              </strong>
              <small>{booking.schedule} · Online</small>
              <StatusBadge status={booking.status} />
            </div>
            <Icon name="chevron" size={18} />
          </button>
        ))}
      </div>
    </div>
  );
}
