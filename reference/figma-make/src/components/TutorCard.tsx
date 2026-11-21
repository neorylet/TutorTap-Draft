import type { Tutor } from "../data/sampleData";
import { StatusBadge } from "./StatusBadge";

export function TutorCard({
  tutor,
  grid,
  onClick,
}: {
  tutor: Tutor;
  grid?: boolean;
  onClick: () => void;
}) {
  return (
    <button className={`tutor-card ${grid ? "grid" : ""}`} onClick={onClick}>
      <span className="avatar">{tutor.initials}</span>
      <span className="tutor-copy">
        <span className="name-line">
          <strong>{tutor.name}</strong>
          <StatusBadge status="Verified" />
        </span>
        <span className="tags">
          {tutor.subjects.map((subject) => (
            <i key={subject}>{subject}</i>
          ))}
        </span>
        <span className="rating">
          ★ {tutor.rating} ({tutor.reviews})
        </span>
        <span className="rate">
          ₱{tutor.rate}/hr <StatusBadge status="Online" />
        </span>
      </span>
    </button>
  );
}
