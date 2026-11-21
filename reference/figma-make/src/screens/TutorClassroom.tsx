import { useState } from "react";
import { FormField } from "../components/FormField";
import { Icon } from "../components/Icon";
import { ListRow } from "../components/ListRow";
import { PillButton } from "../components/PillButton";
import { useAppState } from "../state/AppState";

export function TutorClassroom() {
  const [tab, setTab] = useState("Modules");
  const { go } = useAppState();
  return (
    <div className="screen tab-screen">
      <h1>Classroom</h1>
      <p className="muted">Build and manage learning materials.</p>
      <div className="inner-tabs">
        {["Modules", "Assignments", "Exams"].map((item) => (
          <button className={tab === item ? "active" : ""} key={item} onClick={() => setTab(item)}>
            {item}
          </button>
        ))}
      </div>
      {tab === "Modules" && (
        <>
          <div className="card compact-form">
            <h2>Upload module</h2>
            <FormField label="Title" placeholder="Module title" />
            <FormField label="Description" placeholder="Short overview" />
            <button className="upload-button">
              <Icon name="upload" /> Choose file
            </button>
            <PillButton>Upload module</PillButton>
          </div>
          <div className="card flush">
            <ListRow title="Algebra Basics.pdf" meta="1.2 MB · Dec 12" />
            <ListRow title="Functions Practice Set.pdf" meta="820 KB · Dec 15" />
          </div>
        </>
      )}
      {tab === "Assignments" && (
        <>
          <div className="card compact-form">
            <h2>Create assignment</h2>
            <FormField label="Title" placeholder="Assignment title" />
            <FormField label="Instructions" placeholder="What should students submit?" textarea />
            <FormField label="Due date" placeholder="Dec 28, 11:59 PM" />
            <PillButton>Create assignment</PillButton>
          </div>
          <h2>Submissions</h2>
          <ListRow
            title="Mika Santos · Linear Equations"
            meta="Submitted Dec 18"
            onClick={() => go("grading")}
          />
        </>
      )}
      {tab === "Exams" && (
        <div className="card compact-form">
          <h2>Create tutor exam</h2>
          <FormField label="Title" placeholder="Quiz title" />
          <FormField label="Time limit" placeholder="15 minutes" />
          <FormField label="Question 1" placeholder="Write the prompt" textarea />
          <FormField label="Assign to students" placeholder="All Math students" />
          <PillButton>Create exam</PillButton>
        </div>
      )}
    </div>
  );
}
