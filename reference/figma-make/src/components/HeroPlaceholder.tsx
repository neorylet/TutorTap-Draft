export function HeroPlaceholder({ compact = false }: { compact?: boolean }) {
  return (
    <div className={`hero-placeholder ${compact ? "compact" : ""}`}>
      <div className="study-card one" />
      <div className="study-card two" />
      <div className="hero-copy">
        <span className="subject-tag">Math</span>
        <h3>Algebra Foundations</h3>
      </div>
      <span className="pending-art">Hero Visual — Pending Final Art</span>
    </div>
  );
}
