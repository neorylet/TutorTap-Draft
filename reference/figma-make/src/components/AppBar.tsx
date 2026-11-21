import { useAppState } from "../state/AppState";
import { Icon } from "./Icon";

export function AppBar({ title, action }: { title: string; action?: React.ReactNode }) {
  const { back } = useAppState();
  return (
    <header className="app-bar">
      <button className="icon-button" onClick={back} aria-label="Go back">
        <Icon name="back" />
      </button>
      <h1>{title}</h1>
      <div className="app-action">{action}</div>
    </header>
  );
}
