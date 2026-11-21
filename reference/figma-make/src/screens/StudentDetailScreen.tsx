import { AppBar } from "../components/AppBar";
import { Icon } from "../components/Icon";
import { PillButton } from "../components/PillButton";
import { meetingLink } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function StudentDetailScreen() {
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Student details" />
      <div className="student-head">
        <span className="avatar large">MS</span>
        <div>
          <h1>Mika Santos</h1>
          <span className="subject-tag">Math</span>
        </div>
      </div>
      <div className="stat-grid three">
        <div>
          <strong>6</strong>
          <span>Sessions</span>
        </div>
        <div>
          <strong>92%</strong>
          <span>Avg grade</span>
        </div>
        <div>
          <strong>5</strong>
          <span>Submitted</span>
        </div>
      </div>
      <section>
        <h2>Recent grades</h2>
        <div className="card grades-compact">
          <div>
            <span>Linear Equations</span>
            <strong>9/10</strong>
          </div>
          <div>
            <span>Graphing Functions</span>
            <strong>18/20</strong>
          </div>
        </div>
      </section>
      <section>
        <h2>Upcoming session</h2>
        <div className="card">
          <strong>Sat, Dec 20 · 2:00–3:00 PM</strong>
          <div className="meeting-link">
            <Icon name="video" size={18} />
            <span>{meetingLink}</span>
          </div>
        </div>
      </section>
      <div className="button-pair">
        <PillButton variant="secondary" disabled>
          <Icon name="message" size={18} /> Message · Coming soon
        </PillButton>
        <PillButton onClick={() => go("grading")}>View submissions</PillButton>
      </div>
    </div>
  );
}
