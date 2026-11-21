import { AppBar } from "../components/AppBar";
import { FormField } from "../components/FormField";
import { PillButton } from "../components/PillButton";
import { useAppState } from "../state/AppState";

export function GradingScreen() {
  const { back } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Grade submission" />
      <div className="card assignment-brief">
        <small>Mika Santos · Submitted Dec 18</small>
        <h2>Homework 1: Linear Equations</h2>
        <p>I solved each equation by isolating x and checked my answers by substitution.</p>
        <button className="file-attachment">
          Linear_Equations_Mika.pdf <span>1.4 MB</span>
        </button>
      </div>
      <FormField label="Score" placeholder="__ / 10" />
      <FormField label="Feedback" placeholder="Write specific, useful feedback" textarea />
      <PillButton onClick={back}>Save grade</PillButton>
    </div>
  );
}
