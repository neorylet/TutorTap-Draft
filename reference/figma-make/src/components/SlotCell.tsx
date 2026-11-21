export function SlotCell({
  time,
  state,
  onClick,
}: {
  time: string;
  state: "available" | "selected" | "locked" | "taken";
  onClick?: () => void;
}) {
  return (
    <button className={`slot ${state}`} disabled={state === "taken"} onClick={onClick}>
      <span>{time}</span>
      {state === "locked" && <small>Held 04:32</small>}
    </button>
  );
}
