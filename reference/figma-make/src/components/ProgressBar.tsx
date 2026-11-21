export function ProgressBar({ value, label }: { value: number; label?: string }) {
  return (
    <div className="progress-wrap">
      {label && (
        <div className="progress-label">
          {label}
          <span>{value}%</span>
        </div>
      )}
      <div className="progress">
        <span style={{ width: `${value}%` }} />
      </div>
    </div>
  );
}
