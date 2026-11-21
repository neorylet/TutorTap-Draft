import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { Icon } from "../components/Icon";
import { PillButton } from "../components/PillButton";
import { useAppState, type Role } from "../state/AppState";

export function RoleSelectScreen() {
  const [choice, setChoice] = useState<Role | null>(null);
  const { setRole, go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="" />
      <h1>How will you use TutorTap?</h1>
      <p className="muted">Choose a workspace. You can switch roles during the demo.</p>
      <div className="role-cards">
        <button
          className={choice === "student" ? "selected" : ""}
          onClick={() => setChoice("student")}
        >
          <span className="role-icon">
            <Icon name="book" size={28} />
          </span>
          <span>
            <strong>Student / Parent</strong>
            <small>Book tutors and study.</small>
          </span>
          {choice === "student" && (
            <i>
              <Icon name="check" size={14} />
            </i>
          )}
        </button>
        <button className={choice === "tutor" ? "selected" : ""} onClick={() => setChoice("tutor")}>
          <span className="role-icon">
            <Icon name="users" size={28} />
          </span>
          <span>
            <strong>Tutor</strong>
            <small>Teach and manage your classroom.</small>
          </span>
          {choice === "tutor" && (
            <i>
              <Icon name="check" size={14} />
            </i>
          )}
        </button>
      </div>
      <PillButton
        disabled={!choice}
        onClick={() => {
          if (!choice) return;
          setRole(choice);
          go(choice === "student" ? "student-home" : "tutor-dashboard");
        }}
      >
        Continue
      </PillButton>
    </div>
  );
}
