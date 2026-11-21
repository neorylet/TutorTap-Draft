export function SegmentedControl({
  items,
  value,
  onChange,
}: {
  items: string[];
  value: string;
  onChange: (item: string) => void;
}) {
  return (
    <div className="segmented">
      {items.map((item) => (
        <button
          key={item}
          className={value === item ? "active" : ""}
          onClick={() => onChange(item)}
        >
          {item}
        </button>
      ))}
    </div>
  );
}
