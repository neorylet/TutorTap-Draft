export function FilterChip({
  label,
  active,
  onClick,
}: {
  label: string;
  active?: boolean;
  onClick?: () => void;
}) {
  return (
    <button className={`filter-chip ${active ? "active" : ""}`} onClick={onClick}>
      {active && <span aria-hidden>✓</span>}
      {label}
    </button>
  );
}
