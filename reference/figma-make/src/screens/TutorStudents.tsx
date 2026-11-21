import { Icon } from "../components/Icon";
import { students } from "../data/sampleData";
import { useAppState } from "../state/AppState";

export function TutorStudents() {
  const { go } = useAppState();
  return (
    <div className="screen tab-screen">
      <h1>Students</h1>
      <p className="muted">Track progress across your classroom.</p>
      <label className="search-field">
        <Icon name="search" size={18} />
        <input placeholder="Search students" />
      </label>
      <div className="stack">
        {students.map((student) => (
          <button
            className="card student-row"
            key={student.id}
            onClick={() => go("student-detail")}
          >
            <span className="avatar">{student.initials}</span>
            <div>
              <strong>{student.name}</strong>
              <i>{student.subject}</i>
              <small>
                Sessions completed {student.sessions} · Avg grade {student.grade}%
              </small>
            </div>
            <Icon name="chevron" size={18} />
          </button>
        ))}
      </div>
    </div>
  );
}
