import { useState } from "react";
import { useAppState, type DemoState } from "../state/AppState";
import { Icon } from "./Icon";

const states: [string, DemoState][] = [
  ["Default", "default"],
  ["Empty Search", "empty"],
  ["Slot Taken Error", "slot-error"],
  ["Uploading", "uploading"],
  ["Upload Failed", "upload-failed"],
];
export function DemoStatesBar() {
  const [open, setOpen] = useState(false);
  const { demo, forceDemo } = useAppState();
  return (
    <div className={`demo-bar ${open ? "open" : ""}`}>
      <button className="demo-toggle" onClick={() => setOpen(!open)}>
        Demo States <Icon name="chevron" size={14} />
      </button>
      {open && (
        <div className="demo-chips">
          {states.map(([label, value]) => (
            <button
              key={value}
              className={demo === value ? "active" : ""}
              onClick={() => {
                forceDemo(value);
                setOpen(false);
              }}
            >
              {label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
