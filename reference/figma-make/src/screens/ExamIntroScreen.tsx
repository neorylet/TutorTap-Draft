import { AppBar } from "../components/AppBar";
import { Icon } from "../components/Icon";
import { PillButton } from "../components/PillButton";
import { useAppState } from "../state/AppState";

export function ExamIntroScreen() {
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Exam details" />
      <div className="exam-intro-art">
        <Icon name="file" size={40} />
      </div>
      <h1>Quiz 1: Functions</h1>
      <p className="muted">A short check of linear functions, slope, domain, and range.</p>
      <div className="card exam-facts">
        <div>
          <Icon name="file" />
          <span>
            <strong>10 questions</strong>
            <small>Multiple choice</small>
          </span>
        </div>
        <div>
          <Icon name="clock" />
          <span>
            <strong>15 minutes</strong>
            <small>Timer starts after launch</small>
          </span>
        </div>
        <div>
          <Icon name="calendar" />
          <span>
            <strong>Due Dec 23</strong>
            <small>One attempt</small>
          </span>
        </div>
      </div>
      <PillButton onClick={() => go("quiz")}>Start exam</PillButton>
    </div>
  );
}
