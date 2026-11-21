import { Icon } from "../components/Icon";
import { PillButton } from "../components/PillButton";
import { meetingLink } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function TutorDashboard() {
  const { go } = useAppState();
  return (
    <div className="screen tab-screen">
      <div className="home-head">
        <div>
          <small>Saturday, December 19</small>
          <h1>Good afternoon, Ana</h1>
        </div>
        <span className="avatar-button">AR</span>
      </div>
      <div className="stat-grid three">
        <div>
          <strong>4</strong>
          <span>
            Upcoming
            <br />
            sessions
          </span>
        </div>
        <div>
          <strong>12</strong>
          <span>
            Active
            <br />
            students
          </span>
        </div>
        <div>
          <strong>₱8,640</strong>
          <span>
            This month
            <br />
            payout
          </span>
        </div>
      </div>
      <section>
        <h2>Next online session</h2>
        <div className="card tutor-session">
          <div className="person-line">
            <span className="avatar small">MS</span>
            <div>
              <strong>Mika Santos</strong>
              <small>Math · Today, 2:00–3:00 PM</small>
            </div>
          </div>
          <div className="meeting-link">
            <Icon name="video" size={18} />
            <span>{meetingLink}</span>
            <button>Copy</button>
          </div>
          <PillButton>Start session</PillButton>
        </div>
      </section>
      <section>
        <h2>Needs attention</h2>
        <button className="card attention-row" onClick={() => go("grading")}>
          <span className="row-icon">
            <Icon name="file" />
          </span>
          <div>
            <strong>To grade</strong>
            <small>3 submissions waiting</small>
          </div>
          <Icon name="chevron" />
        </button>
      </section>
      <section>
        <h2>Today</h2>
        <div className="timeline">
          <div>
            <span>2:00</span>
            <i />
            <p>
              <strong>Mika Santos</strong>
              <small>Algebra review · Online</small>
            </p>
          </div>
          <div>
            <span>4:30</span>
            <i />
            <p>
              <strong>Rafael Uy</strong>
              <small>Functions practice · Online</small>
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
