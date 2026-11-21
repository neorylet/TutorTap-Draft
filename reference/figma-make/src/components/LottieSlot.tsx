import { Icon } from "./Icon";

export function LottieSlot({
  file,
  size = 160,
  compact = false,
}: {
  file: string;
  size?: number;
  compact?: boolean;
}) {
  return (
    <div
      className={`lottie-slot ${compact ? "compact" : ""}`}
      style={{ width: size, minHeight: compact ? size : Math.min(size, 220) }}
    >
      <span className="play-badge">
        <Icon name="play" size={18} />
      </span>
      <div className="lottie-lines">
        <i />
        <i />
        <i />
      </div>
      <span className="lottie-caption">{file}</span>
    </div>
  );
}
