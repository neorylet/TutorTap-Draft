import { useState } from "react";
import { Icon } from "../components/Icon";
import { ListRow } from "../components/ListRow";
import { PillButton } from "../components/PillButton";
import { StatusBadge } from "../components/StatusBadge";
import { assignments, exams } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function StudentClassroom() {
  const [tab, setTab] = useState("Modules");
  const { go } = useAppState();
  return (
    <div className="screen tab-screen">
      <h1>Classroom</h1>
      <p className="muted">Math · Ana Reyes</p>
      <div className="inner-tabs four">
        {["Modules", "Assignments", "Exams", "Grades"].map((item) => (
          <button key={item} className={tab === item ? "active" : ""} onClick={() => setTab(item)}>
            {item}
          </button>
        ))}
      </div>
      {tab === "Modules" && (
        <div className="card flush">
          <ListRow
            title="Algebra Basics.pdf"
            meta="1.2 MB · Uploaded Dec 12"
            action={
              <button className="mini-action">
                <Icon name="download" size={16} /> Download
              </button>
            }
          />
          <ListRow
            title="Functions Practice Set.pdf"
            meta="820 KB · Uploaded Dec 15"
            action={
              <button className="mini-action">
                <Icon name="download" size={16} /> Download
              </button>
            }
          />
        </div>
      )}
      {tab === "Assignments" && (
        <div className="stack">
          {assignments.map((a) => (
            <button className="card assignment-row" key={a.id} onClick={() => go("assignment")}>
              <div>
                <strong>{a.title}</strong>
                <small>Due {a.due}</small>
              </div>
              <StatusBadge status={a.status} />
            </button>
          ))}
        </div>
      )}
      {tab === "Exams" && (
        <div className="stack">
          {exams.map((exam) => (
            <div className="card exam-row" key={exam.id}>
              <div>
                <strong>{exam.title}</strong>
                <small>
                  {exam.questions} questions · {exam.minutes} min · Due {exam.due}
                </small>
              </div>
              {exam.score ? (
                <StatusBadge status={exam.score} />
              ) : (
                <PillButton onClick={() => go("exam-intro")}>Take exam</PillButton>
              )}
            </div>
          ))}
        </div>
      )}
      {tab === "Grades" && (
        <div className="stack">
          <div className="card grade-card">
            <div>
              <strong>Homework 1: Linear Equations</strong>
              <span>9/10</span>
            </div>
            <p>Clear steps. Watch your sign on question 4.</p>
          </div>
          <div className="card grade-card">
            <div>
              <strong>Quiz 1: Functions</strong>
              <span>8/10</span>
            </div>
            <p>Review domain and range notation.</p>
          </div>
        </div>
      )}
    </div>
  );
}
